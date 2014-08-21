require 'dotenv'
require 'mysql'
Dotenv.load

days_back = 10
base_query = 'SELECT count(*) as count, conversation_rating as rating FROM conversation WHERE DATE(startTime) = "%s" AND conversation_rating IS NOT NULL GROUP BY conversation_rating'

con = Mysql.new(ENV['MYSQL_HOST'], ENV['MYSQL_USER'], ENV['MYSQL_PASS'], ENV['MYSQL_DB'])

time = Time.now.utc - 60*60*24*(days_back + 1)

data = []
(0..days_back).each do |i|
  query = base_query % time.strftime('%Y-%m-%d')
  rs = con.query(query)

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
  data << {x: time.to_i, y: rating.to_i}

  time += 60*60*24
end

SCHEDULER.every '24h', :first_in => 0 do |job|
  send_event("rating", {points: data})
end

