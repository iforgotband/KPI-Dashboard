require 'dotenv'
require 'mysql'
Dotenv.load

days_back = 10
base_query = 'SELECT count(*) as count FROM conversation WHERE DATE(startTime) = "%s"'

con = Mysql.new(ENV['MYSQL_HOST'], ENV['MYSQL_USER'], ENV['MYSQL_PASS'], ENV['MYSQL_DB'])

time = Time.now.utc - 60*60*24*(days_back + 1)

data = []
(0..days_back).each do |i|
  query = base_query % time.strftime('%Y-%m-%d')
  rs = con.query(query)

  count = 0
  rs.each_hash do |h|
    count = h['count']
  end

  data << {x: time.to_i, y: count.to_i}

  time += 60*60*24
end

SCHEDULER.every '24h', :first_in => 0 do |job|
  send_event("count", {points: data})
end

