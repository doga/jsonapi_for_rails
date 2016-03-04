class Author < ApplicationRecord
  has_many :articles
  validates_presence_of :email
end
