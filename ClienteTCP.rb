require 'socket' # Sockets are in standard library

class Client
  attr_reader :temperatura, :acoustico, :s, :idCliente


  def initialize()
    @temperatura = 0.0
    @acoustico = 0.0
    @s = TCPSocket.open('localhost', 2000)
    @X = 0.0
    @Y = 0.0
    @seconds = 1
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

  def setX(pos_x, pos_y)
    @X=pos_x
    @Y=pos_y
  end

  def leituras()
    t1=Thread.new { read }
    #	t3=Thread.new{fim}
    t1.join
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

  def read
    while true
      sleep(1)
      if (@seconds <5)
        readAco
        time2 = Time.now
        @s.puts ("2/#{@acoustico},#{time2.to_s},")
        @seconds = @seconds + 1
      else
        readAco
        time2 = Time.now
        @s.puts ("2/#{@acoustico},#{time2.to_s},")
        readTemp
        time1 = Time.now
        @s.puts("1/#{@temperatura},#{time1.inspect.to_s},")
        @seconds = 1
      end
    end
  end

  def main
    id = ARGV
    #puts "#{id[0]} --- #{id[1]}"
    @s.puts "#{id[0]}/#{id[1]}/"
    id = @s.gets
    puts "A conexão foi feita com sucesso e o seu ID é #{id}"
    @idCliente = id
    leituras
  end

end

c = Client.new()
c.main