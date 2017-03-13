require 'socket'
require 'sqlite3'

class Server
	attr_reader :server, :cliente#, :bd

	def initialize()
	    @server = TCPServer.open(2000)
	    #@bd =  SQLite3::Database.open 'WeatherStation.db'
  	end

	def starts
		loop {                         # Servers run forever
		    Thread.start(@server.accept) do |client|
		    	@cliente=client
		    	s = @cliente.gets
		    	puts s
				insertBD
		      	@cliente.close          # Disconnect from the client
		    end
		}
	end

	def insertBD
		while true
			s = @cliente.gets
			tipoLeitura,leitura = s.split("/")
			puts tipoLeitura
			puts leitura
			if tipoLeitura == '1' then
				bdTemp
			else
				#bdAco
				puts "aco"
			end
		end
	end

	def bdTemp
		puts '3'
		temp,timezone = leitura.split(",")
		puts "#{temp}"
		puts timezone
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