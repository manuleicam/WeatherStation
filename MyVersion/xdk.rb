class XDK
  def initialize()
    @temperatura = 0.0
    @acoustico = 0.0

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



  def send()

  end
end

  c = XDK.new
  c.readAco
  c.readTemp
  puts c.getAco
  puts c.getTemp