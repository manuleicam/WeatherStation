require 'socket'
require 'sqlite3'

class Server
	attr_reader :server, :cliente, :bd

	def initialize()
	    @server = TCPServer.open(2000)
	    @bd =  SQLite3::Database.open 'WeatherStation.db'
  	end

	def starts
		loop {                         # Servers run forever
		    Thread.start(@server.accept) do |client|
		    	@cliente=client 
		    	gps = @cliente.gets
		    	#puts "#{gps}"
		    	lat,lon = gps.split("/")
		    	#puts "#{lat} -- #{lon}"
		    	id = getID(lat,lon)
		    	puts "#{id} + pça"
		    	#id = @cliente.get		#recebe o ID do cliente
		    	#puts id
				insertBD(id,lat,lon)
		      	@cliente.close          # Disconnect from the client
		    end
		}
	end

	def getID(lat,lon)
		#puts lat
		#puts lon
		stm = @bd.prepare "Select count(*) From leituras Where GPSX = #{lat} and GPSY = #{lon} LIMIT 1;"
		rs = stm.execute
		row = rs.next
		#puts "#{row[0]}+1"
		if row[0] == 1 then
			stm = @bd.prepare "Select IDCLIENTE From leituras Where GPSX = #{lat} and GPSY = #{lon} LIMIT 1;"
			rs = stm.execute
			row = rs.next
			id = row.join "\s"
        	#puts id
        else
        	stm = @bd.prepare "Select max(IDCLIENTE) From leituras;"
			rs = stm.execute
			row = rs.next
			#puts row
			#puts "#{row[0]}"
			id = row[0] + 1
			puts "#{id}"
			#row += 1
			#id = row.join "\s"
			#id += 1
			#puts row
        end
    	return id

	end

	def insertBD(id,lat,lon)
		while true
			s = @cliente.gets
			tipoLeitura,leitura = s.split("/")
			#puts tipoLeitura
			#puts leitura
			if tipoLeitura == '1' then
				bdTemp(leitura, id, lat, lon)
			else
				bdAco(leitura,id, lat, lon)
				#puts "aco"
			end
		end
	end

	def bdTemp(leitura, id, lat, lon)
		temp,timezone = leitura.split(",")
		tipo = 2
		#puts tipo
		#puts lat
		#puts lon
		@bd.execute("INSERT INTO leituras (IDCLIENTE, IDSENSOR, VALUE, GPSX, GPSY, TIMESTAMP)
			VALUES (?, ?, ?, ?, ?, ?);", id, tipo, temp, lat, lon, timezone)
	end

	def bdAco(leitura,id, lat, lon)
		temp,timezone = leitura.split(",")
		tipo = 1
		#puts tipo
		#puts lat
		#puts lon
		@bd.execute("INSERT INTO leituras (IDCLIENTE, IDSENSOR, VALUE, GPSX, GPSY, TIMESTAMP)
			VALUES (?, ?, ?, ?, ?, ?);", id, tipo, temp, lat, lon, timezone)
	end

	#def funcs

	#end

	def maine
	  	t1=Thread.new{starts}
		#t2=Thread.new{funcs}
		t1.join
		#t2.join
	end
end
s = Server.new()
s.maine