require 'socket'

class Server
	attr_reader :server, :cliente

	def initialize()
	    @server = TCPServer.open(2000)
  	end

	def starts
		loop {                         # Servers run forever
		    Thread.start(@server.accept) do |client|
		    	while true
					s = client.gets
		    		puts s.chomp
		    	end
		      	@cliente.close          # Disconnect from the client
		    end
		}
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