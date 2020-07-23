require_relative '../lib/mysql2-query-logger.rb'
require 'mysql2'
require 'mysql2-cs-bind'

Mysql2QueryLogger.enable

def run
  client = Mysql2::Client.new(database: 'test')
  client.query('select * from users limit 1').first
  client.prepare('select * from users where id = ?').execute(1).first
  client.xquery('select * from users where id = ?', 1).first
  client.query('select sleep(0.1)').first
  client.query('select sleep(0.01)').first
end

run
