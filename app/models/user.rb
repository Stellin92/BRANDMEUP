class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :outfits, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_one_attached :photo
  # has_outfits? method
  # This method checks if the user has at least one outfit and return a boolean

  def has_outfit?
    result = self.outfits.length > 0 ? true : false
  end

end
