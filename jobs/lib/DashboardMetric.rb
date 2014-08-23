require_relative 'DataAccessor'

class DashboardMetric
  @@days_back = 10

  attr_accessor :data, :data_accessor

  def initialize
    @data = []
    @data_accessor = DataAccessor.instance
    @time = @data_accessor.lastDay - @@days_back

    (0..@@days_back).each do |i|
      @data << self.get_data
      @time += 1
    end
  end

  def update
    if @time.to_date < @data_accessor.lastDay
      @data.shift
      @time += 1
      @data << self.get_data
    end
  end
end