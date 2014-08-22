require 'dotenv'
require_relative 'lib/DataAccessor'
Dotenv.load

days_back = 10
base_query = 'SELECT count(*) as count, engaged FROM conversation WHERE DATE(startTime) = "%s" GROUP BY engaged'



def get_data time, query
  query = query % time.strftime('%Y-%m-%d')
  rs = DataAccessor.instance.query(query)

  engaged = nonengaged = 0
  rs.each_hash do |h|
    if h['engaged'] == '1'
      engaged = h['count'].to_f
    else
      nonengaged = h['count'].to_f
    end
  end

  percent = engaged / (engaged + nonengaged) * 100

  {'x' => time.to_i, 'y' => percent.to_i}
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

  send_event('engagement', {points: data})
  send_event('engagement-number', {current: data[-1]['y'], last: data[-8]['y']})
end

