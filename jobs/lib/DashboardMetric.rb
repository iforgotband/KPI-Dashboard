require_relative 'DataAccessor'

class DashboardMetric
  @@days_back = 10

  attr_accessor :data, :data_accessor

  def initialize
    @time = Time.now - 60*60*24*(@@days_back + 1)
    @data = []
    @data_accessor = DataAccessor.instance

    (0..@@days_back).each do |i|
      @data << self.get_data
      @time += 60*60*24
    end
  end

  def update
    if @time.to_date < @data_accessor.lastDay
      @data.shift
      @time += 60*60*24
      @data << self.get_data
    end
  end
end