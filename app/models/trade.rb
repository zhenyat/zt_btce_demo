class Trade < ApplicationRecord
  belongs_to :pair
  enum status: %w(ask bid) 
end
