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

class Train
  attr_reader :type, :actions

  def self.from_user_input
    puts 'Введите номер нового поезда:'
    number = gets.to_i
    
    puts "Выберете тип поезда:\n1. Пассажирский\n2. Грузовой"
    choice = gets.to_i
    case choice
    when 1 then PassengerTrain.new(number)
    when 2 then CargoTrain.new(number)
    end
  end
  
  def initialize(number)
    @number = number
    @speed = 0
    @wagons = []
    @actions = {assign_a_route: 'Назначить маршрут', 
                attach_wagon: 'Прицепить вагон'}
  end

  def process_action(action, route = nil)
    case action
    when :detach_wagon then self.detach_wagon(@wagons.last)
    when :assign_a_route then self.assign_a_route(route)
    when :go_to_next_station then self.go_to_next_station
    when :go_to_previous_station then self.go_to_previous_station      
    end
  end

  def to_s
    "Поезд № #{@number}, вагонов: #{@wagons.size}"
  end

  protected

  def speed_up(additional_speed=80)
    @speed += additional_speed
  end

  def brake
    @speed = 0
  end

  def attach_wagon(wagon)
    unless @speed == 0
      puts 'Ошибка. Невозможно присоединить вагон, когда поезд движется.'
      return nil
    end
    @actions[:detach_wagon] = 'Отцепить вагон'
  end

  def detach_wagon(wagon)
    if @speed == 0
      @wagons.delete(wagon)
      puts 'Вагон отцеплен'
      @actions.delete(:detach_wagon) if @wagons.empty?
    else    
      puts 'Ошибка. Невозможно отсоединить вагон, когда поезд движется.'
    end
  end

  def assign_a_route(route)
    current_station.depart(self) if @route
    
    @route = route
    @current_location_index = 0
    current_station.handle(self)
    puts 'Маршрут назначен'

    @actions[:go_to_next_station] = 'Поехать на следующую станцию маршрута'
    @actions[:go_to_previous_station] = 'Поехать на предыдущую станцию маршрута'
  end

  def go_to_next_station
    if @current_location_index == @route.stations.size - 1
      puts 'Ошибка, поезд на последней станции маршрута.'
    else
      station = current_station
      current_station.depart(self)
      @current_location_index += 1
      current_station.handle(self)
      puts "Поезд прибыл на станцию #{current_station}"
    end
  end

  def go_to_previous_station
    if @current_location_index == 0
      puts 'Ошибка, поезд на первой станции маршрута.'
    else
      current_station.depart(self)
      @current_location_index -= 1
      current_station.handle(self)
      puts "Поезд прибыл на станцию #{current_station}"
    end
  end

  def previous_station
    unless @current_location_index == 0
      @route.stations[@current_location_index - 1]
    end
  end

  def current_station
    @route.stations[@current_location_index] if @route
  end

  def next_station
    unless @current_location_index == @route.stations.size - 1
      @route.stations[@current_location_index + 1]
    end
  end

  def info
    "Поезд № #{@number}\nВагонов: #{@wagons.size}.\nМаршрут: #{@route}\n" \
    "Сейчас находится на станции #{current_station}. " \
    "Предыдущая станция маршрута: #{previous_station}. " \
    "Следующая станция маршрута: #{next_station}. "
  end
end
