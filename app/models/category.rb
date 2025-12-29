# app/models/category.rb
class Category < ApplicationRecord
  has_many :services

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
end
