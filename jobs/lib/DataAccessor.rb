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

end