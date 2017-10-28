=begin
Класс Train (Поезд):
Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество 
  вагонов, эти данные указываются при создании экземпляра класса
Может набирать скорость
Может возвращать текущую скорость
Может тормозить (сбрасывать скорость до нуля)
Может возвращать количество вагонов
Может прицеплять/отцеплять вагоны (по одному вагону за операцию, метод просто 
  увеличивает или уменьшает количество вагонов). Прицепка/отцепка вагонов может 
  осуществляться только если поезд не движется.
Может принимать маршрут следования (объект класса Route). 
При назначении маршрута поезду, поезд автоматически помещается на первую 
  станцию в маршруте.
Может перемещаться между станциями, указанными в маршруте. Перемещение возможно 
  вперед и назад, но только на 1 станцию за раз.
Возвращать предыдущую станцию, текущую, следующую, на основе маршрута
=end

class Train
  attr_reader :type
  
  def initialize(number, type, number_of_wagons)
    @number = number
    @type = type
    @number_of_wagons = number_of_wagons
    @speed = 0
    @route = nil
    @current_location_index = nil
  end

  def speed_up(additional_speed=80)
    @speed += additional_speed
  end

  def brake
    @speed = 0
  end

  def attach_wagon
    if @speed != 0
      puts 'Ошибка. Невозможно присоединить вагон, когда поезд движется.'
    else
      @number_of_wagons += 1
    end
  end

  def detach_wagon
    if @speed != 0
      puts 'Ошибка. Невозможно отсоединить вагон, когда поезд движется.'
    elsif @number_of_wagons == 1
      puts 'Ошибка. Невозможно отсоединить последний вагон.'
    else    
      @number_of_wagons -= 1
    end
  end

  def assign_a_route(route)
    @route = route
    speed_up
    @current_location_index = 0
    current_station.handle(self)
    brake    
  end

  def go_to_next_station
    if @current_location_index == @route.all_stations.size - 1
      puts 'Ошибка, поезд на последней станции маршрута.'
    else
      current_station.depart(self)
      speed_up
      @current_location_index += 1
      current_station.handle(self)      
      brake
    end
  end

  def go_to_previous_station
    if @current_location_index == 0
      puts 'Ошибка, поезд на первой станции маршрута'
    else
      current_station.depart(self)
      speed_up
      @current_location_index -= 1
      current_station.handle(self)
      brake      
    end
  end

  def previous_station
    if @current_location_index == 0
      'Поезд на первой станции маршрута'
    else
      @route.all_stations[@current_location_index - 1]
    end
  end

  def current_station
    @route ? @route.all_stations[@current_location_index] : 'Депо'
  end

  def next_station
    if @current_location_index == @route.all_stations.size - 1
      'Поезд на последней станции маршрута'
    else
      @route.all_stations[@current_location_index + 1]
    end
  end

  def info
    "Поезд № #{@number}\nВагонов: #{@number_of_wagons}.\nМаршрут: #{@route}\n" \
    "Сейчас находится на станции #{current_station}. " \
    "Предыдущая станция маршрута: #{previous_station}. " \
    "Следующая станция маршрута: #{next_station}. "
  end

  def to_s
    "Поезд № #{@number}"
  end
end
