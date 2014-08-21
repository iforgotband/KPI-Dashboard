require 'dotenv'
require 'mysql'
Dotenv.load

days_back = 10
base_query = 'SELECT count(*) as count, engaged FROM conversation WHERE DATE(startTime) = "%s" GROUP BY engaged'

con = Mysql.new(ENV['MYSQL_HOST'], ENV['MYSQL_USER'], ENV['MYSQL_PASS'], ENV['MYSQL_DB'])

time = Time.now.utc - 60*60*24*(days_back + 1)

data = []
(0..days_back).each do |i|
  query = base_query % time.strftime('%Y-%m-%d')
  rs = con.query(query)

  engaged = nonengaged = 0
  rs.each_hash do |h|
    if h['engaged'] == '1'
      engaged = h['count'].to_f
    else
      nonengaged = h['count'].to_f
    end
  end

  percent = engaged / (engaged + nonengaged) * 100
  data << {x: time.to_i, y: percent.to_i}

  time += 60*60*24
end

SCHEDULER.every '24h', :first_in => 0 do |job|
  send_event("engagement", {points: data})
end

