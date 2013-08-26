require 'data_mapper'

DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/db/database.sqlite3")
Dir[File.dirname(__FILE__) + "/models/*.rb"].each {|f| require f }

DataMapper.finalize
DataMapper.auto_upgrade!
