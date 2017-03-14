module Subject

  def initialize
    @observers = []
  end

  def add_observer(observer)
    @observers << obj
  end

  def delete_observer(observer)
    @observers.delete(observer) ## not sure about this
  end

  def Notify
    for observer in @observers
      observer.Update()
    end
  end
end