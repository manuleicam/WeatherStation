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
		    	id = @cliente.get		#recebe o ID do cliente
		    	puts id
				insertBD(id)
		      	@cliente.close          # Disconnect from the client
		    end
		}
	end

	def insertBD(id)
		while true
			s = @cliente.gets
			tipoLeitura,leitura = s.split("/")
			#puts tipoLeitura
			#puts leitura
			if tipoLeitura == '1' then
				bdTemp(leitura, id)
			else
				#bdAco
				#puts "aco"
			end
		end
	end

	def bdTemp(leitura, id)
		temp,timezone = leitura.split(",")
		tipo = 2
		gps = 5
		@bd.execute("INSERT INTO leituras (IDCLIENTE, IDSENSOR, VALUE, GPSX, GPSY, TIMESTAMP)
			VALUES (?, ?, ?, ?, ?, ?);", id, tipo, temp, gps, gps, timezone)
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