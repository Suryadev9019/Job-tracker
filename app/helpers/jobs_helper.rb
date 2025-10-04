module JobsHelper
  def status_badge_class(status)
    case status&.downcase
    when 'applied'
      'bg-blue-100 text-blue-800'
    when 'interview'
      'bg-yellow-100 text-yellow-800'
    when 'offer'
      'bg-green-100 text-green-800'
    when 'rejected'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end
