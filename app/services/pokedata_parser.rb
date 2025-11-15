module PokedataParser
  def self.parse_release_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

 def self.normalize_name(name)
    name.to_s.downcase.gsub(/[^a-z0-9-]/, "")
  end

  def self.extract_first_number(card_number)
    return "" if card_number.nil? || card_number.empty?
    # Filter out leading zeros and second number or convert nil to ""
    num = card_number.to_s[/^[A-Za-z0-9]+/] || ""
    # Subs in first number or nil for ''
    first_number = num.sub(/^0+/, '') # remove leading zeros if numeric
    # Result is K097/K099 => K97 or nil => "" for error handling
    first_number
  end
end
