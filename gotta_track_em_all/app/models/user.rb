class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :collections, dependent: :destroy
  has_many :collection_cards, through: :collections
  has_many :cards, through: :collection_cards

  # Trainer type
  TRAINER_TYPES = %w[pokescientist pokemaniac]

  validates :trainer_type, presence: true, inclusion: { in: TRAINER_TYPES }

  def pokescientist?
    trainer_type == "pokescientist"
  end

   def pokemaniac?
    trainer_type == "pokemaniac"
   end
end
