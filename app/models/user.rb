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

  # Average price of all cards
  def average_card_price
    total_card_value.fdiv(collection_cards.count)
  end

  # Most valuable card
  def most_valuable_card
    collection_cards.to_a.sort_by do |card|
      price = card.fetch_price
      price || 0
    end.last
  end

  # Most valuable set (grouped by set_name)
  def most_valuable_set
    set_values ={}
    collection_cards.each do |card|
      price = card.fetch_price
      set = card.card.set_name

      if set_values[set].nil?
        set_values[set] = price
      else
        set_values[set]+= price
      end
    end
    set_values.max_by { |k, v| v }.first
  end
end
