require 'active_record'

ENV['RACK_ENV'] ||= 'development'

def sqlite_db name
  File.join(File.dirname(__FILE__), "./db/#{name}.sqlite3")
end

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database  => sqlite_db(ENV['RACK_ENV'].to_sym)
)
