require_relative 'station'
require_relative 'train'
require_relative 'route'
require_relative 'passenger_train'
require_relative 'cargo_train'

# Класс хранит текущий список объектов, а также возможные действия пользователя 
# в главном меню в виде хеша {символ: соответствующий метод}.
# Когда юзер выбирает действие, в метод process_main_menu передается символ, 
# и он запускает соответствующий метод (для удобства назову такие методы 
# подметодами).

# Подметод определяет, какие ему нужны данные для вызова методов 
# станций, маршрутов и поездов. И ещё при необходимости добавляет пункты 
# в главное меню (если уже созданы две станции, то должна появиться возможность 
# создать маршрут и т.п.). 

# Далее с помощью служебных методов choose (возвращает выбранный из массива 
# объект) и choose_action (принимает хеш, возвращает символ) у юзера выясняем, 
# что конкретно делаем, и запускаем нужный метод выбранного инстанса или класса.

class Interface
  attr_reader :main_menu

  def initialize
    @stations =[]
    @routes = []
    @trains = []

    @main_menu = {
      add_station: 'Создать станцию', 
      add_train: 'Создать поезд'
    }
  end

  def process_main_menu(action)
    case action
    when :add_station then add_station
    when :add_train then add_train
    when :add_route then add_route
    when :manage_route then manage_route
    when :manage_train then manage_train
    when :show_station_info then show_station_info
    else
      exit
    end
  end

  def choose_action(actions_hash, 
                    exit_option = false,
                    question = 'Выберете действие:')
    puts question
    actions_hash.values.each_with_index { |action, i| puts "#{i+1}. #{action}" }
    puts 'Для выхода из программы нажмите любую другую клавишу.' if exit_option
    puts 

    choice = gets.to_i
    if choice == 0 && exit_option
      :exit
    else
      actions_hash.keys[choice - 1]
    end
  end

  def add_station
    puts 'Введите название для новой станции:'
    @stations << Station.new(gets.chomp)
  rescue RuntimeError => error_message
    puts error_message
    puts
    retry
  ensure
    add_main_menu_option(:add_route, 'Добавить маршрут') if @stations.size >= 2
    add_main_menu_option(:show_station_info, 'Показать поезда на станции')
    puts "Станция #{@stations.last} создана"
  end

  def add_train
    puts "Выберете тип поезда:\n1. Пассажирский\n2. Грузовой"
    choice = gets.to_i

    puts 'Введите номер нового поезда:'
    number = gets.chomp

    begin
    @trains << case choice
               when 1 then PassengerTrain.new(number)
               when 2 then CargoTrain.new(number)
               end
    rescue RuntimeError => error_message
      puts error_message
      puts
      puts 'Введите номер нового поезда:'
      number = gets.chomp
      retry
    end

    add_main_menu_option(:manage_train, 'Управлять поездом')
    puts "#{@trains.last} создан."
  end

  def new_passenger_wagon
    puts "Введите количество мест в вагоне."
    seats_number = gets.to_i
    PassengerWagon.new(seats_number)
  rescue RuntimeError => error_message
    puts error_message
    puts
    retry
  end

  def new_cargo_wagon
    puts "Укажите объем вагона в кубических метрах."
    capacity = gets.to_i
    CargoWagon.new(capacity)
  rescue RuntimeError => error_message
    puts error_message
    puts
    retry
  end
  
  def add_route
    departure_station = choose(@stations, 
                               question = 'Выберете станцию отправления:')
    destination_station = choose(@stations, 
                                 question = 'Выберете станцию назначения:')
    @routes << Route.new(departure_station, destination_station)
  rescue RuntimeError => error_message
    puts error_message
    puts
    retry
  ensure
    add_main_menu_option(:manage_route, 'Управлять маршрутом')
    puts "Маршрут #{@routes.last} создан."
  end

  def manage_route
    route = choose(@routes, question = 'Выберете маршрут:')
    action_key = choose_route_action(route)
    process_route_action(route, action_key)
  end
  
  def manage_train
    train = choose(@trains, question = 'Выберете поезд:')
    action_key = choose_train_action(train)
    process_train_action(train, action_key)    
  end

  def show_station_info
    station = choose(@stations, question = 'Выберете станцию:')

    if station.trains.empty?
      puts "На станции #{station} нет поездов"
    else
      puts "Сейчас на станции #{station} следующие поезда:"
      station.each_train { |train| puts "#{train}" }
    end
  end

  private

  def choose(items, question = nil)
    if items.size == 1
      puts "Автоматически выбран единственный объект: #{items.first}"
      return items.first
    end

    puts question
    items.each_with_index { |item, i| puts "#{i+1}. #{item}" }

    choice = gets.to_i
    items[choice - 1]
  end

  def add_main_menu_option(key, description)
    main_menu[key] = description unless main_menu.has_key?(key)
  end

  def choose_route_action(route)
    actions = {add_intermediate_station: 'Добавить станцию',
               remove_intermediate_station: 'Удалить станцию'}
    choose_action(actions)
  end

  def choose_train_action(train)
    actions = {attach_wagon: 'Прицепить вагон',
               assign_a_route: 'Назначить маршрут'}

    if train.wagons.any?
      actions[:detach_wagon] = 'Отсоединить вагон'
      actions[:show_all_wagons] = 'Посмотреть все вагоны'

      if train.is_a? PassengerTrain
        actions[:occupy_a_seat] = 'Занять место в вагоне'
      else
        actions[:fill_wagon] = 'Занять объем в вагоне'
      end
    end

    if train.route
      actions[:go_to_next_station] = 'Поехать на следующую станцию'
      actions[:go_to_previous_station] = 'Поехать на предыдущую станцию'
    end

    choose_action(actions)
  end

  def process_route_action(route, action_key)
    case action_key
    when :add_intermediate_station then add_intermediate_station(route)
    when :remove_intermediate_station then remove_intermediate_station(route)
    end
  end

  def add_intermediate_station(route)
    stations_to_add = @stations - route.stations
    if stations_to_add.any?
      station = choose(stations_to_add, question = 'Выберете станцию:')
      route.add_intermediate_station(station)
      puts "Станция #{station} добавлена в маршрут."
    else
      puts 'Ошибка, нет станций, которые можно было бы добавить в маршрут.'
    end
  end

  def remove_intermediate_station(route)
    stations_to_remove = route.stations[1...-1]
    if stations_to_remove.any?
      station = choose(stations_to_remove, question = 'Выберете станцию:')
      route.remove_intermediate_station(station)
      puts "Станция #{station} удалена из маршрута"
    else
      puts 'Ошибка, в маршруте нет промежуточных станций.'
    end
  end

  def process_train_action(train, action_key)
    case action_key
    when :attach_wagon then attach_wagon(train)
    when :detach_wagon then detach_wagon(train)
    when :assign_a_route then assign_a_route(train)
    when :go_to_next_station then go_to_next_station(train)     
    when :go_to_previous_station then go_to_previous_station(train)
    when :show_all_wagons then show_all_wagons(train)
    when :occupy_a_seat then occupy_a_seat(train)
    when :fill_wagon then  fill_wagon(train)
    end
  end

  def attach_wagon(train)
    unless train.speed == 0
      puts 'Ошибка. Невозможно присоединить вагон, когда поезд движется.'
      return nil
    end

    if train.is_a? PassengerTrain
      train.attach_wagon(new_passenger_wagon)
      puts 'Пассажирский вагон прицеплен'
    elsif train.is_a? CargoTrain
      train.attach_wagon(new_cargo_wagon)
      puts 'Грузовой вагон прицеплен'
    end
  end

  def detach_wagon(train)
    unless train.speed == 0
      puts 'Ошибка. Невозможно отсоединить вагон, когда поезд движется.'
      return nil
    end

    train.detach_wagon(train.wagons.last)
    puts 'Вагон отцеплен'
  end

  def assign_a_route(train)
    if @routes.empty?
      puts 'Ошибка. Ни одного маршрута пока не создано.'
    else
      route = choose(@routes, question = 'Выберете маршрут:')
      train.assign_a_route(route)
      puts 'Маршрут назначен'
    end
  end

  def go_to_next_station(train)
    if train.on_last_station?
      puts 'Ошибка, поезд на последней станции маршрута.'
    else
      train.go_to_next_station
      puts "Поезд прибыл на станцию #{train.current_station}"
    end
  end

  def go_to_previous_station(train)
    if train.on_first_station?
      puts 'Ошибка, поезд на первой станции маршрута.'
    else
      train.go_to_previous_station
      puts "Поезд прибыл на станцию #{train.current_station}"
    end
  end

  def show_all_wagons(train)
    train.each_wagon { |wagon, i| puts "#{i + 1}. #{wagon}" }
  end

  def occupy_a_seat(train)
    begin
      wagon = choose(train.wagons, question = 'Выберете вагон:')
      wagon.occupy_a_seat
      puts "Место занято, в вагоне осталось #{wagon.available_seats} "\
      "свободных мест."
    rescue RuntimeError => error_message
      puts error_message
      puts
      retry
    end
  end

  def fill_wagon(train)
    begin
      wagon = choose(train.wagons, question = 'Выберете вагон:')
      puts 'Введите объем, который нужно занять, в кубических метрах:'
      volume = gets.to_i
      wagon.fill_wagon(volume)
      puts "Готово, в этом вагоне свободно ещё #{wagon.available_volume} м³."
    rescue RuntimeError => error_message
      puts error_message
      puts
      retry
    end
  end
end
