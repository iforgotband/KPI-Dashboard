require_relative 'DataAccessor'

class DashboardMetric
  @@days_back = 10 # cannot be lower than 9

  attr_accessor :data, :data_accessor

  def initialize
    @data = []
    @data_accessor = DataAccessor.instance
    @time = @data_accessor.lastDay - @@days_back
  end

  def update
    while @time.to_date < @data_accessor.lastDay
      if @data.length > @@days_back
        @data.shift
      end
      @time += 1
      @data << self.get_data
    end
  end
end
