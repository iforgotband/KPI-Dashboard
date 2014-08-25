require_relative 'lib/DashboardMetric'

class Engagement < DashboardMetric

  @@query = 'SELECT count(*) as count, engaged FROM conversation WHERE DATE(CONVERT_TZ(startTime, "+00:00", "-04:00")) = "%s" GROUP BY engaged'

  def get_data
    query = @@query % @time.strftime('%Y-%m-%d')
    rs = @data_accessor.query(query)

    engaged = nonengaged = 0
    rs.each_hash do |h|
      if h['engaged'] == '1'
        engaged = h['count'].to_f
      else
        nonengaged = h['count'].to_f
      end
    end

    percent = engaged / (engaged + nonengaged) * 100

    {'x' => @time.to_time.to_i, 'y' => percent.to_i}
  end
end

engage = Engagement.new

SCHEDULER.every '30m', :first_in => '1s' do |job|
  engage.update

  send_event('engagement', {points: engage.data})
  send_event('engagement-number', {current: engage.data[-1]['y'], last: engage.data[-8]['y']})
end

