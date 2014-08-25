require_relative 'lib/DashboardMetric'

class NewTexters < DashboardMetric

  @@query = 'SELECT count(*) as count FROM actor a WHERE type != "Internal" AND id NOT IN (
              SELECT actor_id FROM message WHERE DATE(CONVERT_TZ(timestamp, "+00:00", "-04:00")) < "%s"
            ) AND id IN (
              SELECT actor_id FROM message WHERE DATE(CONVERT_TZ(timestamp, "+00:00", "-04:00")) < "%s"
            );'

  def get_data
    query = @@query % [@time.strftime('%Y-%m-%d'), (@time + 60*60*24).strftime('%Y-%m-%d')]
    rs = @data_accessor.query(query)

    count = 0
    rs.each_hash do |h|
      count = h['count']
    end

    {'x' => @time.to_time.to_i, 'y' => count.to_i}
  end
end

nt = NewTexters.new

SCHEDULER.every '30m', :first_in => '1s' do |job|
  nt.update

  send_event('new-texters', {points: nt.data})
  send_event('new-texters-number', {current: nt.data[-1]['y'], last: nt.data[-8]['y']})
end
