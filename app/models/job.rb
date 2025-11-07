class Job < ApplicationRecord
  belongs_to :user

  validates :title , :company, :location,  presence: true
end
