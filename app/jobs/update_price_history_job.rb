class UpdatePriceHistoryJob < ApplicationJob

  def perform(card_id)

    card = Card.find(card_id)


    # Check if a price history has been pulled in the last 24 hours
    last_update = card.price_histories.order(recorded_at: :desc).first
    if last_update && last_update.recorded_at >= Date.current
      Rails.logger.info("Price history for card #{card_id} was updated today, skipping")
      return
    end

    pricing_response = HTTParty.get(
      "https://api.scrydex.com/pokemon/v1/cards",
      timeout: 60,
      headers: { "X-Api-Key" => ENV["SCRYDEX_API_KEY"], "X-Team-ID" => "gtea" },
      query: { id: card.api_tcg_id, include: "prices" }
    )

    unless pricing_response.success?
      Rails.logger.error("Scrydex pricing failed: #{pricing_response.code}")
      return
    end

    pricing_data = pricing_response.parsed_response.dig("data", 0)
    return { error: "No Scrydex pricing data found" } if pricing_data.nil?

    variants = pricing_data.fetch("variants", [])
    pricing = build_pricing_data(variants)
    selected_variant = find_variant_for(card, variants)
    raw_price = preferred_raw_price(selected_variant) || preferred_raw_price_from(variants)

    return { error: "No raw price found" } if raw_price.nil?

    pricing["Raw"] = normalized_price(raw_price)
    psa_pricing = graded_pricing(variants, "PSA")
    cgc_pricing = graded_pricing(variants, "CGC")

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
      recorded_at: Time.current
    )

    Rails.logger.info("Successfully created price history for card #{card.id}")

  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Card #{card_id} not found")
  rescue HTTParty::Error => e
    Rails.logger.error("HTTP error fetching pricing for card #{card_id}: #{e.message}")
    raise
  rescue StandardError => e
    Rails.logger.error("Failed to fetch pricing for card #{card_id}: #{e.message}")
    raise
  end

  private

  def build_pricing_data(variants)
    variants.each_with_object({}) do |variant, result|
      variant.fetch("prices", []).each do |price|
        next if price_value(price).nil?

        key = "#{variant['name']} Raw #{price['condition']}"
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

    prices = variant.fetch("prices", []).select { |price| price["type"] == "raw" }
    prices.find { |price| price["condition"] == "NM" && price_value(price).present? } ||
      prices.find { |price| price_value(price).present? }
  end

  def preferred_raw_price_from(variants)
    variants.filter_map { |variant| preferred_raw_price(variant) }.first
  end

  def graded_pricing(variants, company)
    variants.each_with_object({}) do |variant, result|
      variant.fetch("prices", []).each do |price|
        next unless price["company"]&.casecmp?(company) && price["grade"].present?
        next if price_value(price).nil?

        key = "#{company} #{price['grade']}"
        result[key] = normalized_price(price).merge("variant" => variant["name"])
      end
    end
  end

  def normalized_price(price)
    price.merge("value" => price_value(price))
  end

  def price_value(price)
    price["market"] || price["mid"] || price["low"] || price["high"]
  end
end
