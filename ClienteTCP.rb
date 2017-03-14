require 'socket' # Sockets are in standard library
require File.dirname(__FILE__) + '/subject.rb'

class Client
  include Subject
  attr_reader :temperatura, :acoustico, :s
  @@number_of_clients = 0

  def initialize()
    @temperatura = 0.0
    @acoustico = 0.0
    @s = TCPSocket.open('localhost', 2000)
    @x = 0.0
    @y = 0.0
    @@counter = @@counter + 1
    @id_client = @@counter
    @observers = Array.new
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
    @x=pos_x
    @y=pos_y
  end

  def leituras()
    t1=Thread.new { temp }
    t2=Thread.new { aco }
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
      self.Notify
      time1 = Time.now
      puts "Current Time temp : " + time1.to_s
      update("1/#{@temperatura},#{time1.inspect.to_s}")
      #@s.puts ("Current Time : #{time1.to_s} \n")
      #@s.puts ("A temperatura é #{@temperatura} \n")
      sleep(2)
    end
  end

  def aco
    while true
      readAco
      time2 = Time.now
      puts "Current Time : " + time2.to_s
      update("2/#{@acoustico},#{time2.to_s}")
      #@s.puts ("A acostica é #{@acoustico}")
      sleep(10)
    end
  end

  def main
    id = ARGV
    @s.puts "#{id[0]}"
    leituras
  end

end
c = Client.new()
c.main