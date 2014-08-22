require 'dotenv'
require_relative 'lib/DataAccessor'
Dotenv.load

days_back = 10
base_query = 'SELECT count(*) as count, conversation_rating as rating FROM conversation
  WHERE DATE(startTime) = "%s" AND conversation_rating IS NOT NULL GROUP BY conversation_rating'


def get_data time, query
  query = query % time.strftime('%Y-%m-%d')
  rs = DataAccessor.instance.query(query)

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

  {'x' => time.to_i, 'y' => rating.to_i}
end

data = []
time = Time.now.utc - 60*60*24*(days_back + 1)

(0..days_back).each do |i|
  data << get_data(time, base_query)
  time += 60*60*24
end

SCHEDULER.every '30m', :first_in => 0 do |job|
  if time.to_date < Time.now.utc.to_date
    data.shift
    time += 60*60*24
    data << get_data(time, base_query, data)
  end

  send_event('rating', {points: data})
  send_event('rating-number', {current: data[-1]['y'], last: data[-8]['y']})
end

