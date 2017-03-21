require 'sqlite3'


class BD

	def initialize()
		@db = SQLite3::Database.new "weatherStation.db"
		@db
	end
	#db =  SQLite3::Database.open 'WeatherStation.db'
	#db.execute 'drop table if exists weatherStation'

	def createTable
		stm = @db.prepare "CREATE TABLE IF NOT EXISTS leituras (
				IDCLIENTE INT NOT NULL,
				IDSENSOR INT NOT NULL,
				VALUE INT NOT NULL,
				GPSX INT NOT NULL,
				GPSY INT NOT NULL,
				TIMESTAMP TEXT NOT NULL
			);"

		rs = stm.execute
		rs.close
	end

	#stm = db.prepare "INSERT INTO leituras (IDCliente, IDSensor, Value, GpsX, GpsY, GpsY)
	#	VALUES (1, 2, 3, 5, 4, 'Fool');"

	#stm = db.prepare "INSERT INTO leituras (IDCLIENTE, IDSENSOR, VALUE, GPSX, GPSY, TIMESTAMP)
	#	VALUES (1, 2, 3, 5, 4, 'Fool');"
	#
	#rs = stm.execute
	#
	#stm = db.prepare "SELECT * FROM leituras;"
	#
	#rs =stm.execute
	##
	#row = rs.next
	#    
	#puts row.join "\s"
end