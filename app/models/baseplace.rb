class Baseplace < ApplicationRecord
  validates :kyoten_name,  presence: true, length: { maximum: 20 }
  validates :kyoten_shurui,  presence: true, length: { maximum: 20 }
end
