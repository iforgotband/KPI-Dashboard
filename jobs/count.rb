require_relative 'lib/DashboardMetric'

class Count < DashboardMetric
  @@query = 'SELECT count(*) as count FROM conversation WHERE DATE(startTime) = "%s"'

  def get_data
    query = @@query % @time.strftime('%Y-%m-%d')
    rs = @data_accessor.query(query)

    count = 0
    rs.each_hash do |h|
      count = h['count']
    end

    {'x' => @time.to_i, 'y' => count.to_i}
  end
end

count = Count.new

SCHEDULER.every '30m', :first_in => 0 do |job|
  count.update

  send_event('count', {points: count.data})
  send_event('count-number', {current: count.data[-1]['y'], last: count.data[-8]['y']})
end

