require 'socket'
require 'sqlite3'
require_relative 'BD'

class Server
  attr_reader :server, :cliente, :bd
  @n_of_reads

  def initialize()
    @server = TCPServer.open(2000)
    @bd = SQLite3::Database.open 'WeatherStation.db'
    @clients_connected = Array.new
  end

  def client_connected(id, lat, lon) #Print da conexão de um cliente
    puts("Cliente com o id #{id} connectado com localização #{lat} #{lon}")
  end

  def client_disconnect(id) #Print quando o cliente se desliga
    puts("Cliente com o id #{id} desconectou-se e fez #{Thread.current['@n_of_reads']} leituras")
  end


  def connected_loca #imprime a localização de todos os clientes connectados
    for client_id in @clients_connected
      @bd.execute("Select IDCLIENTE,GPSX,GPSY From leituras where IDCLIENTE = ? LIMIT 1;", client_id)
    end
  end

  def run
    b = BD.new
    b.createTable
    Thread.new {
      loop {# Servers run forever
        Thread.start(@server.accept) do |client|
          Thread.current['@n_of_reads'] = 0
          gps = client.gets
          lat, lon = gps.split("/")
          id = getID(lat, lon, client)
          @clients_connected << id
          client_connected(id,lat,lon) #Print da conexão de um cliente
          lerMensagem(id, lat, lon, client) #O servidor descodifica a mensagem
        end
      }
    }
  end


  def getClients()
    puts "Lista de Clientes conectados"
    puts "#{@clients_connected}"
    for id_client in @clients_connected do
      stm = @bd.prepare "Select distinct GPSX,GPSY From leituras Where IDCLIENTE = #{id_client}"
      rs = stm.execute
      row = rs.next
      puts "IDCLIENT: #{id_client} GpsX: #{row[0]} e GPSY : #{row[1]}"
    end
  end

  def getSensorValues(id_client,id_sensor)
    puts "Valores Sensores"
    stm = @bd.prepare "Select Value From leituras Where IDCLIENTE = #{id_client} and IDSENSOR = #{id_sensor};"
    rs = stm.execute
    while(row=rs.next)
      puts "IDSENSOR:#{id_sensor}, Valor #{row[0]}"
    end
  end

  def getID(lat, lon, client)
    stm = @bd.prepare "Select count(*) From leituras Where GPSX = #{lat} and GPSY = #{lon} LIMIT 1;"
    rs = stm.execute
    row = rs.next
    if row[0] >= 1 then
      stm = @bd.prepare "Select IDCLIENTE From leituras Where GPSX = #{lat} and GPSY = #{lon} LIMIT 1;"
      rs = stm.execute
      row = rs.next
      id = row.join "\s"
      client.puts "#{id},"
    else
      stm = @bd.prepare "SELECT EXISTS(SELECT * FROM leituras);"
      rs = stm.execute
      row = rs.next
      if row[0] == 1
        stm = @bd.prepare "Select max(IDCLIENTE) From leituras;"
        rs = stm.execute
        row = rs.next
        id = row[0] + 1
        client.puts "#{id},"
      else
        id = 1
        client.puts "#{id},"
      end
    end
    return id

  end

  def lerMensagem(id, lat, lon, client) #O servidor descodifica a mensagem
    while true
      s = client.gets
      tipoLeitura, leitura = s.split("/")
      if tipoLeitura == '1' then
        bdTemp(leitura, id, lat, lon) #insere uma leitura de temperatura
      elsif tipoLeitura == '2' then
        bdAco(leitura, id, lat, lon) #insere uma leitura de acustica
      else
        id_remove, n_of_reads = leitura.split(",")
        @clients_connected.delete(id_remove.to_i) #Remove o ID que se desligou do array
        client_disconnect(id_remove) #Print quando o cliente se desliga
      end
    end
  end

  def bdTemp(leitura, id, lat, lon) #insere uma leitura de temperatura
    temp, timezone = leitura.split(",")
    tipo = 2
    @bd.execute("INSERT INTO leituras (IDCLIENTE, IDSENSOR, VALUE, GPSX, GPSY, TIMESTAMP)
			VALUES (?, ?, ?, ?, ?, ?);", id, tipo, temp, lat.to_i, lon.to_i, timezone)
    Thread.current['@n_of_reads'] = Thread.current['@n_of_reads'] + 1
  end

  def bdAco(leitura, id, lat, lon) #insere uma leitura de acustica
    temp, timezone = leitura.split(",")
    tipo = 1
    @bd.execute("INSERT INTO leituras (IDCLIENTE, IDSENSOR, VALUE, GPSX, GPSY, TIMESTAMP)
			VALUES (?, ?, ?, ?, ?, ?);", id, tipo, temp, lat.to_i, lon.to_i, timezone)
    Thread.current['@n_of_reads'] = Thread.current['@n_of_reads'] + 1
  end

  def start
    t1=Thread.new { run }
    t1.join
  end
end