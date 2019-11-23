class Baseplace < ApplicationRecord
  validates :kyoten_id,  presence: true, length: { maximum: 3 }, uniqueness: true, numericality: true
  validates :kyoten_name,  presence: true, length: { maximum: 20 }
  validates :kyoten_shurui,  presence: true, length: { maximum: 20 }
end
