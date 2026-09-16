class User < ApplicationRecord
  attr_accessor :login

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: %i[login]
  has_many :collections, dependent: :destroy
  has_many :collection_cards, through: :collections
  has_many :cards, through: :collection_cards
  has_many :search_attempts, dependent: :destroy
  has_one_attached :avatar
  before_validation :create_first_collection, on: :create
  before_validation :assign_default_avatar, on: :create
  validates :collections, presence: true
  # Trainer type
  TRAINER_TYPES = %w[pokescientist pokemaniac]

  validates :trainer_type, presence: true, inclusion: { in: TRAINER_TYPES }
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  def pokescientist?
    trainer_type == "pokescientist"
  end

  def pokemaniac?
    trainer_type == "pokemaniac"
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)&.to_s&.strip&.downcase

    Rails.logger.debug "Authenticating with login: #{login}"

    return nil if login.blank?

    where(conditions).where(
      "lower(username) = :value OR lower(email) = :value",
      { value: login.strip.downcase }
    ).first
  end
  # Total value of all cards
  def total_card_value
    collection_cards.sum do |card|
      price = card.fetch_price
      price || 0
    end
  end

  # Average known price; unavailable prices do not count as zero-value cards.
  def average_card_price
    prices = collection_cards.filter_map(&:fetch_price)
    return 0.0 if prices.empty?

    prices.sum.fdiv(prices.length)
  end

  # Most valuable card
  def most_valuable_card
    # collection_cards.to_a.sort_by do |card|
    #   price = card.fetch_price
    #   price || 0
    # end.last
    collection_cards.includes(:price_histories, :card).max_by do |card|
      card.fetch_price.to_f.round(2)
    end
  end

  # Most valuable set (grouped by set_name)
  def most_valuable_set
    # Set hash to default value of 0 to deal with nil values
    set_values = Hash.new(0)
    collection_cards.includes(:card).each do |card|
      price = card.fetch_price.to_f
      set = card.card&.set_name || "Unknown Set"
      set_values[set]+= price
    end
    set_name, total = set_values.max_by { |_set, total| total } || [ nil, nil ]
    { set_name: set_name, total: total }
  end

  def favourites
    collection_cards.where(favourite: true)
  end

  private

  def create_first_collection
    return if collections.any?

      collections.build(
        name: "First Collection",
        description: "Feel free to add cards to this collection or create another one
                      of your own. You'll need a collection to add cards to",
      )
  end

  def assign_default_avatar
    nil if preset_avatar.present? || avatar.attached?

    self.preset_avatar =
      case self.trainer_type
      when "pokemaniac" then "pokemaniac_avatar.png"
      when "pokescientist" then "scientist_m_avatar.png"
      end
  end
end
