class User < ApplicationRecord
  has_many :outfits

  # has_outfits? method
  # This method checks if the user has at least one outfit and return a boolean

  def has_outfit?
    result = self.outfits.length > 0 ? true : false
  end

  def delete_outfit(outfit)
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
