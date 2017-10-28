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
  def initialize(departure_station, destination_station)
    @departure_station = departure_station
    @destination_station = destination_station
    @intermediate_stations = []
  end
  
  def add_intermediate_station(station)
    @intermediate_stations << station
  end
  
  def remove_intermediate_station(station)
    @intermediate_stations.delete(station)
  end

  def all_stations
    [@departure_station] + @intermediate_stations + [@destination_station]
  end

  def to_s
    all_stations.join(' - ')   
  end
end
