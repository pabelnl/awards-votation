class Voter < ApplicationRecord
  validates :email, uniqueness: true
  
end
