require 'socket' # Sockets are in standard library

class Client
  attr_reader :temperatura, :acoustico, :s, :idCliente

  def initialize(x, y)
    @temperatura = 0.0
    @acoustico = 0.0
    @s = TCPSocket.open('localhost', 2000)
    @X = x
    @Y = y
    @seconds = 1
    @n_of_reads = 0
    @disconnect_flag = false
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
    #	t3=Thread.new{fim}
    t1.join
    #	t3.join
  end

  def read

    Thread.new {
      while (@disconnect_flag == false)
            sleep(1)
        if (@seconds <30)
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
          @seconds = 1 ## PARA TESTAR A SAIDA DO CLIENTE
          #puts "#{@n_of_reads}, #{@disconnect_flag}"
        end
      end
    }
  end

  def disconnect
    @s.puts "3/#{@idCliente}, #{@n_of_reads},"
    @disconnect_flag = true
    puts("#{@n_of_reads}")
    s.close
  end

  def main
    @s.puts "#{@X}/#{@Y}/"
    id, n = @s.gets.split(",")
    puts "A conexão foi feita com sucesso e o seu ID é #{id}"
    @idCliente = id
    leituras
  end

end
