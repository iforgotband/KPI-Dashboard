require 'singleton'
require 'mysql'
require 'dotenv'

Dotenv.load

class DataAccessor
  include Singleton
  attr_reader :connection

  def initialize
    @connection = Mysql.new(ENV['MYSQL_HOST'], ENV['MYSQL_USER'], ENV['MYSQL_PASS'], ENV['MYSQL_DB'], ENV['MYSQL_PORT'].to_i)
  end

  def query(query)
    @connection.query(query)
  end

  def lastDay
    rs = @connection.query('select timestamp from message order by id desc limit 1')
    Date.parse(rs.fetch_row[0]) - 1
  end

end