require 'socket' # Sockets are in standard library

class Client
  @temperatura
  @acoustico
  @clientSocket
  @idCliente
  @lat
  @lon
  @n_of_reads
  @disconnect_flag

  def initialize(lat, lon)
    @temperatura = 0.0
    @acoustico = 0.0
    @clientSocket= TCPSocket.open('localhost', 2000)
    @lat = lat
    @lon = lon
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

  def setX(lat, lon)
    @lat=lat
    @lon=lon
  end

  def read
    t1=Thread.new { readSensors }
    t1.join
  end

  def readSensors
    Thread.new {
      while (@disconnect_flag == false)
        sleep(1)
        if (@seconds <30)
          readAco
          @clientSocket.puts ("2/#{@acoustico},#{Time.now.to_s},")
          @seconds = @seconds + 1
        else
          readAco
          @clientSocket.puts ("2/#{@acoustico},#{Time.now.to_s},")
          readTemp
          @clientSocket.puts("1/#{@temperatura},#{Time.now.inspect.to_s},")
          @seconds = 1
        end
      end
    }
  end

  def disconnect
    @clientSocket.puts "3/#{@idCliente}, #{@n_of_reads},"
    @disconnect_flag = true
    puts("#{@n_of_reads}")
    @clientSocket.close
  end

  def connect
    @clientSocket.puts "#{@lat}/#{@lon}/"
    id, n = @clientSocket.gets.split(",")
    puts "A conexão foi feita com sucesso e o seu ID é #{id}"
    @idCliente = id
    read
  end

end
