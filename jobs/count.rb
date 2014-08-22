require 'dotenv'
require_relative 'lib/DataAccessor'
Dotenv.load

days_back = 10
base_query = 'SELECT count(*) as count FROM conversation WHERE DATE(startTime) = "%s"'


def get_data time, query
  query = query % time.strftime('%Y-%m-%d')
  rs = DataAccessor.instance.query(query)

  count = 0
  rs.each_hash do |h|
    count = h['count']
  end

  {'x' => time.to_i, 'y' => count.to_i}
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

  send_event('count', {points: data})
  send_event('count-number', {current: data[-1]['y'], last: data[-8]['y']})
end

