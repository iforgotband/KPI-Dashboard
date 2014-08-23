require_relative 'lib/DataAccessor'

class LessThan14
  attr_reader :last, :current

  @@query = 'SELECT (takenFromQueue - addedToQueue) as diff FROM conversation WHERE DATE(CONVERT_TZ(startTime, "+00:00", "-04:00")) = "%s"'

  def initialize
    @today = Time.now - 60*60*24
    @last_week = @today - 60*60*24*7

    @last = self.get_data(@last_week)
    @current = self.get_data(@today)
  end

  def get_data date
    query = @@query % date.strftime('%Y-%m-%d')
    rs = DataAccessor.instance.query(query)

    less = more = 0
    rs.each_hash do |h|
      if h['diff'].to_i < 14*60
        less += 1
      else
        more += 1
      end
    end

    less * 100 / (less + more)
  end

  def update
    if @today.to_date < Time.now.to_date - 60*60*24
      @today += 60*60*24
      @last_week += 60*60*24

      @last = self.get_data(@last_week)
      @current = self.get_data(@today)
    end
  end
end

lt14 = LessThan14.new

SCHEDULER.every '60m', :first_in => 0 do |job|
  lt14.update
  send_event('less-14', {current: lt14.current, last: lt14.last})
end

