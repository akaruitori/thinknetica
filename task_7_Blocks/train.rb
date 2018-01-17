=begin
Класс Train (Поезд):
Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество 
  вагонов, эти данные указываются при создании экземпляра класса
Может набирать скорость
Может возвращать текущую скорость
Может тормозить (сбрасывать скорость до нуля)
Может возвращать количество вагонов
Может прицеплять/отцеплять вагоны (объект вагона должен передаваться 
  как аругмент метода и сохраняться во внутреннем массиве поезда). 
  Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
Может принимать маршрут следования (объект класса Route). 
При назначении маршрута поезду, поезд автоматически помещается на первую 
  станцию в маршруте.
Может перемещаться между станциями, указанными в маршруте. Перемещение возможно 
  вперед и назад, но только на 1 станцию за раз.
Возвращать предыдущую станцию, текущую, следующую, на основе маршрута
=end
require_relative 'company_name'
require_relative 'instance_counter'

class Train
  include CompanyName
  include InstanceCounter

  attr_reader :speed, :number, :route
  attr_accessor :wagons

  NUMBER_FORMAT = /^[a-zа-я\d]{3}-?[a-zа-я\d]{2}$/i

  @@all_by_number = {}

  def self.find(number)
    @@all_by_number[number]
  end

  def initialize(number)
    @number = number
    @speed = 0
    @wagons = []
    
    validate!
    @@all_by_number[number] = self
    register_instance
  end

  def attach_wagon(wagon)
  end

  def detach_wagon(wagon)
    @wagons.delete(wagon)
  end

  def assign_a_route(route)
    current_station.depart(self) if @route
    
    @route = route
    @current_location_index = 0
    current_station.handle(self)
  end

  def go_to_next_station
    current_station.depart(self)
    @current_location_index += 1
    current_station.handle(self)
  end

  def go_to_previous_station
    current_station.depart(self)
    @current_location_index -= 1
    current_station.handle(self)
  end

  def on_first_station?
    @current_location_index == 0    
  end

  def on_last_station?
    @current_location_index == @route.stations.size - 1
  end

  def current_station
    @route.stations[@current_location_index] if @route
  end

  def valid?
    validate!
  rescue
    false
  end

  def each_wagon
    @wagons.each { |wagon| yield(wagon, @wagons.index(wagon)) }
  end

  def to_s
    "Поезд № #{@number} (вагонов: #{@wagons.size})"
  end

  protected

  def validate!
    p @number
    raise 'Номер поезда не может отсутствовать.' if @number.empty?
    raise 'Неверно указан номер поезда.' if @number !~ NUMBER_FORMAT
    true
  end

  def speed_up(additional_speed=80)
    @speed += additional_speed
  end

  def brake
    @speed = 0
  end

  def previous_station
    unless @current_location_index == 0
      @route.stations[@current_location_index - 1]
    end
  end

  def next_station
    unless @current_location_index == @route.stations.size - 1
      @route.stations[@current_location_index + 1]
    end
  end
end
