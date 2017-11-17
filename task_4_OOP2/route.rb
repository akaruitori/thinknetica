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
  attr_reader :stations, :actions

  def initialize(departure_station, destination_station)
    @stations = [departure_station, destination_station]
    @actions = {add_intermediate_station: 'Добавить станцию'}
    puts "Маршрут #{self} создан"
  end

  def process_action(action, station)
    case action
    when :add_intermediate_station
      self.add_intermediate_station(station)
    when :remove_intermediate_station
      self.remove_intermediate_station(station)
    end
  end

  def to_s
    stations.join(' - ')   
  end
  
  def add_intermediate_station(station)
    @stations.insert(-2, station)
    puts "Станция #{station} добавлена в маршрут"
    @actions[:remove_intermediate_station] = 'Убрать станцию'
  end
  
  def remove_intermediate_station(station)
    unless [stations.first, stations.last].include?(station)
      @stations.delete(station)
      puts "Станция #{station} удалена из маршрута"
      @actions.delete(:remove_intermediate_station) if @stations.size == 2
    end    
  end
end
