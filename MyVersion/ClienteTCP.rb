require 'socket' # Sockets are in standard library

class Client
  attr_reader :temperatura, :acoustico, :s
  @@counter = 0
  @disconnect_flag = false

  def initialize()
    @temperatura = 0.0
    @acoustico = 0.0
    @s = TCPSocket.open('localhost', 2000)
    @X = 0.0
    @Y = 0.0
    @seconds = 1
    @@counter = @@counter + 1
    @id_cliente = @@counter
    @n_of_reads = 0
  end

  def readTemp
    @temperatura = rand(-10..50)
    @n_of_reads = @n_of_reads + 1
  end

  def readAco
    @acoustico = rand(0..50)
    @n_of_reads = @n_of_reads + 1
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
    t1.join
  end

  def client_disconnect()
    @s.close
    @disconnect_flag = true
  end

  def read
    #while true
    loop do
      sleep(1)
      if (@seconds <30)
        readAco
        time2 = Time.now
        @s.puts ("2/#{@acoustico},#{time2.to_s}")
        @seconds = @seconds + 1
      else
        readAco
        time2 = Time.now
        @s.puts ("2/#{@acoustico},#{time2.to_s}")
        readTemp
        time1 = Time.now
        @s.puts("1/#{@temperatura},#{time1.inspect.to_s}")
        @seconds = 1
      end
      break if(@disconnect_flag == true)
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