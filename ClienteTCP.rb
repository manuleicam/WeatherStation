require 'socket'      # Sockets are in standard library

class Client
	attr_reader :temperatura, :acoustico, :s


	def initialize()
	    @temperatura = 0.0
	    @acoustico = 0.0
	    @s = TCPSocket.open('localhost', 2000)
  	end

  	def readTemp
   	 	@temperatura = rand(-10..50)
  	end

  	def readAco
    	@acoustico = rand(0..50)
  	end

  	def getTemp
    	@temperatura
  	end

  	def getAco
    	@acoustico
  	end

  	def leituras()
  		t1=Thread.new{temp}
		t2=Thread.new{aco}
	#	t3=Thread.new{fim}
		t1.join
		t2.join
	#	t3.join
	end

	#def fim
	#	while user_input = gets.chomp # loop while getting user input
  	#		case user_input
  	#		when "1"
    #			puts "First response"
    #			break # make sure to break so you don't ask again
  	#		when "2"
    #			puts "Second response"
    #			break # and again
  	#		else
    #			puts "Please select either 1 or 2"
    #			print prompt # print the prompt, so the user knows to re-enter input
  	#		end
	#	end
	#end

	def temp
		while true
			sleep(1)
			readTemp
			time1 = Time.now
			#puts "Current Time : " + time1.to_s
			@s.puts("1/#{@temperatura},#{time1.inspect.to_s}")
			#@s.puts ("Current Time : #{time1.to_s} \n")
			#@s.puts ("A temperatura é #{@temperatura} \n")
			sleep(5)
		end
	end

	def aco
		while true
			readAco
			time2 = Time.now
			puts "Current Time : " + time2.to_s
			@s.puts ("2/#{@acoustico},Current Time : #{time2.to_s}")
			#@s.puts ("A acostica é #{@acoustico}")
			sleep(2)
		end
	end

	def main
		id = ARGV
		@s.puts "O cliente de ID #{id[0]} acabou de se conectar"
		leituras
	end

end
c = Client.new()
c.main