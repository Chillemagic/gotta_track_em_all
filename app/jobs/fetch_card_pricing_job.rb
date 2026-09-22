class FetchCardPricingJob < ApplicationJob
  queue_as :default

  retry_on Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  retry_on HTTParty::Error, wait: 5.minutes, attempts: 3

  def perform(card_id)
    # 1. Find Card from existing card db
    Rails.logger.info("Running FetchCardPricingJob for card #{card_id}")
    card = Card.find(card_id)
    latest_price = card.price_histories.order(recorded_at: :desc, id: :desc).first

    if latest_price.nil? || latest_price.recorded_at.nil? || latest_price.recorded_at <= 24.hours.ago
      pricing_response = HTTParty.get(
        "https://api.scrydex.com/pokemon/v1/cards",
        timeout: 60,
        headers: { "X-Api-Key" => Rails.application.credentials.dig(:scrydex, :api_key), "X-Team-ID" => "gtea" },
        query: { q: "id:#{card.api_tcg_id}", include: "prices" }
      )
      unless pricing_response.success?
        return Rails.logger.error("Scrydex pricing failed: #{pricing_response.code}")
      end

      pricing_data = pricing_response.parsed_response.dig("data", 0)
      if pricing_data.nil?
        return { error: "No Scrydex pricing data found" }
      end

      variants = Array(pricing_data["variants"])
      pricing = build_pricing_data(variants)
      selected_variant = find_variant_for(card, variants)
      raw_price = preferred_raw_price(selected_variant) || preferred_raw_price_from(variants)

      if raw_price.nil?
        return { error: "No raw price found" }
      end

      # Keep a generic Raw option for existing collection cards while retaining
      # every variant and condition in pricing_data.
      pricing["Raw"] = normalized_price(raw_price)

      psa_pricing = graded_pricing([ selected_variant ].compact, "PSA")
      cgc_pricing = graded_pricing([ selected_variant ].compact, "CGC")
      pricing.merge!(psa_pricing).merge!(cgc_pricing)

      # 4. Create price history for card
      card.update!(
        api_tcg_id: pricing_data["id"],
        set_name: pricing_data.dig("expansion", "name"),
        release_date: PokedataParser.parse_release_date(pricing_data.dig("expansion", "release_date"))
      )

      card.price_histories.create!(
        pokedata_id: pricing_data["id"],
        card_name: pricing_data["name"],
        card_number: pricing_data["printed_number"],
        set_name: pricing_data.dig("expansion", "name"),
        release_date: PokedataParser.parse_release_date(pricing_data.dig("expansion", "release_date")),
        psa_pricing: psa_pricing,
        cgc_pricing: cgc_pricing,
        pricing_data: pricing,
        pokedata_raw_price: price_value(raw_price),
        source: "Scrydex",
        recorded_at: Time.current,
        status: "complete"
      )

      Rails.logger.info("Successfully created price history for card #{card_id}")
    else
      # Use most recent price history
      latest_price.update!(status: "matched")
      Rails.logger.info("Most recent price_history is less than 24 hours old, using price_history: #{latest_price.id} for card: #{card.name}, #{card.card_number}")
    end

    SearchAttempt.where(card_id: card.id).find_each(&:broadcast_pricing)

  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Card #{card_id} not found")
  rescue StandardError => e
    Rails.logger.error("Failed to fetch pricing for card #{card_id}: #{e.message}")
    raise
  end

  private

  def build_pricing_data(variants)
    variants.each_with_object({}) do |variant, result|
      Array(variant["prices"]).each do |price|
        next if price_value(price).nil?

        label = case price["type"]
        when "raw" then "Raw #{price['condition']}"
        when "graded"
          next if price["company"].blank? || price["grade"].blank?

          graded_label(price)
        else next
        end
        key = "#{variant['name']} #{label}"
        key += " #{price['currency']}" if price["type"] == "graded" && price["currency"].present?
        result[key] = normalized_price(price).merge("variant" => variant["name"])
      end
    end
  end

  def find_variant_for(card, variants)
    variant_name = case card.holo_type
    when /reverse/i then "reverseHolofoil"
    when /holo/i then "holofoil"
    else "normal"
    end

    variants.find { |variant| variant["name"].casecmp?(variant_name) } || variants.first
  end

  def preferred_raw_price(variant)
    return if variant.nil?

    prices = Array(variant["prices"]).select { |price| price["type"] == "raw" }
    prices.find { |price| price["condition"] == "NM" && price_value(price).present? } ||
      prices.find { |price| price_value(price).present? }
  end

  def preferred_raw_price_from(variants)
    variants.filter_map { |variant| preferred_raw_price(variant) }.first
  end

  def graded_pricing(variants, company)
    variants.each_with_object({}) do |variant, result|
      Array(variant["prices"]).each do |price|
        next unless price["type"] == "graded" && price["company"]&.casecmp?(company) && price["grade"].present?
        next if price_value(price).nil?

        key = graded_label(price.merge("company" => company))
        result[key] = normalized_price(price).merge("variant" => variant["name"])
      end
    end
  end

  def graded_label(price)
    label = "#{price['company']} #{price['grade']}"
    label += " Perfect" if price["is_perfect"]
    label += " Signed" if price["is_signed"]
    label += " Error" if price["is_error"]
    label
  end

  def normalized_price(price)
    price.merge("value" => price_value(price))
  end

  def price_value(price)
    price["market"] || price["mid"] || price["low"] || price["high"]
  end
end
