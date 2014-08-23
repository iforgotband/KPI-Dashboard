require_relative 'lib/DashboardMetric'

class Rating < DashboardMetric

  @@query = 'SELECT count(*) as count, conversation_rating as rating FROM conversation
    WHERE DATE(startTime) = "%s" AND conversation_rating IS NOT NULL GROUP BY conversation_rating'

  def get_data
    query = @@query % @time.strftime('%Y-%m-%d')
    rs = @data_accessor.query(query)

    same = better = worse = 0
    rs.each_hash do |h|
      case h['rating']
        when '-1'
          worse = h['count'].to_i
        when '1'
          same = h['count'].to_i
        when '2'
          better = h['count'].to_i
      end
    end

    rating = ((same * 50) + (better * 100)) / (same + better + worse)

    {'x' => @time.to_i, 'y' => rating.to_i}
  end
end

rating = Rating.new

SCHEDULER.every '30m', :first_in => 0 do |job|
  rating.update

  send_event('rating', {points: rating.data})
  send_event('rating-number', {current: rating.data[-1]['y'], last: rating.data[-8]['y']})
end

