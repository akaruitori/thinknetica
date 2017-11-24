=begin
Класс Route (Маршрут):
Имеет начальную и конечную станцию, а также список промежуточных станций. 
  Начальная и конечная станции указываютсся при создании маршрута, 
  а промежуточные могут добавляться между ними.
Может добавлять промежуточную станцию в список
Может удалять промежуточную станцию из списка
Может выводить список всех станций по-порядку от начальной до конечной
=end

class Route
  attr_reader :stations

  def initialize(departure_station, destination_station)
    @stations = [departure_station, destination_station]
  end

  def to_s
    stations.join(' - ')   
  end
  
  def add_intermediate_station(station)
    @stations.insert(-2, station)    
  end
  
  def remove_intermediate_station(station)
    unless [stations.first, stations.last].include?(station)
      @stations.delete(station)
    end
  end
end
