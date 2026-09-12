module SearchAttemptsHelper
  RAW_CONDITION_NAMES = {
    "NM" => "Near Mint",
    "LP" => "Lightly Played",
    "MP" => "Moderately Played",
    "HP" => "Heavily Played",
    "DM" => "Damaged"
  }.freeze

  def collection_card_condition_label(condition)
    condition.sub(/\bRaw (NM|LP|MP|HP|DM)\z/) do
      abbreviation = Regexp.last_match(1)
      "Raw #{abbreviation} — #{RAW_CONDITION_NAMES.fetch(abbreviation)}"
    end
  end
end
