require 'socket'
require 'sqlite3'

class Server
	attr_reader :server, :cliente, :bd
	

	def initialize()
	    @server = TCPServer.open(2000)
	    @bd =  SQLite3::Database.open 'WeatherStation.db'
	    @clients_connected = Array.new
  	end

  	def client_connected(id, lat, lon) 						#Print da conexão de um cliente
    	puts("Cliente com o id #{id} connectado com localização #{lat} #{lon}")
  	end

	def client_disconnect(id, n_of_reads) 					#Print quando o cliente se desliga
    	puts("Cliente com o id #{id} desconectou-se e fez #{n_of_reads} leituras")
    end


  	
  	def connected_loca										#imprime a localização de todos os clientes connectados
    	for client_id in @clients_connected
      		@bd.execute("Select IDCLIENTE,GPSX,GPSY From leituras where IDCLIENTE = ? LIMIT 1;",client_id)
    	end
  	end

	def starts
		loop {                         # Servers run forever
		    Thread.start(@server.accept) do |client|
		    	@cliente=client 
		    	gps = @cliente.gets
		    	lat,lon = gps.split("/")
		    	id = getID(lat,lon)

		    	client_connected(id,lat, lon)				#Print da conexão de um cliente

		    	@clients_connected[@clients_connected.size] = id.to_i  #adiciona o cliente que se conectou ao array (id em inteiro)
		    	#puts "#{@clients_connected}"
				lerMensagem(id,lat,lon)						#O servidor descodifica a mensagem

		      	@cliente.close          					# Disconnect from the client
		    end
		}
	end

	def getID(lat,lon)
		stm = @bd.prepare "Select count(*) From leituras Where GPSX = #{lat} and GPSY = #{lon} LIMIT 1;"
		rs = stm.execute
		row = rs.next
		if row[0] >= 1 then
			stm = @bd.prepare "Select IDCLIENTE From leituras Where GPSX = #{lat} and GPSY = #{lon} LIMIT 1;"
			rs = stm.execute
			row = rs.next
			id = row.join "\s"
			@cliente.puts "#{id},"
        else
        	stm = @bd.prepare "SELECT EXISTS(SELECT * FROM leituras);"
			rs = stm.execute
			row = rs.next
			if row[0] == 1
        		stm = @bd.prepare "Select max(IDCLIENTE) From leituras;"
				rs = stm.execute
				row = rs.next
				id = row[0] + 1
				@cliente.puts "#{id},"
			else
				id = 1
				@cliente.puts "#{id},"
			end
        end
    	return id

	end

	def lerMensagem(id,lat,lon) 							#O servidor descodifica a mensagem
		while true
			s = @cliente.gets
			tipoLeitura,leitura = s.split("/")
			if tipoLeitura == '1' then
				bdTemp(leitura, id, lat, lon)				#insere uma leitura de temperatura
			elsif tipoLeitura == '2' then
				bdAco(leitura,id, lat, lon)					#insere uma leitura de acustica
			else
				id_remove, n_of_reads = leitura.split(",")
				@clients_connected.delete(id_remove)		#Remove o ID que se desligou do array
				client_disconnect(id_remove, n_of_reads) 	#Print quando o cliente se desliga
			end
		end
	end

	def bdTemp(leitura, id, lat, lon) 						#insere uma leitura de temperatura
		temp,timezone = leitura.split(",")
		tipo = 2
		@bd.execute("INSERT INTO leituras (IDCLIENTE, IDSENSOR, VALUE, GPSX, GPSY, TIMESTAMP)
			VALUES (?, ?, ?, ?, ?, ?);", id, tipo, temp, lat.to_i, lon.to_i, timezone)
	end

	def bdAco(leitura,id, lat, lon)							#insere uma leitura de acustica
		temp,timezone = leitura.split(",")
		tipo = 1
		@bd.execute("INSERT INTO leituras (IDCLIENTE, IDSENSOR, VALUE, GPSX, GPSY, TIMESTAMP)
			VALUES (?, ?, ?, ?, ?, ?);", id, tipo, temp, lat.to_i, lon.to_i, timezone)
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