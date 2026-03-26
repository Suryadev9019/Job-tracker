class Job < ApplicationRecord
  belongs_to :user

  validates :title , :company, :location,  presence: true

  def status_color
    case status&.downcase
    when "pending"
      "amber"
    when "interview"
      "green"
    when "rejected"
      "rose"
    else
      "gray"
    end
  end
end
