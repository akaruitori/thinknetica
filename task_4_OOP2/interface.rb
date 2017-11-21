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
 
    add_main_menu_option(:add_route, 'Добавить маршрут') if @stations.size >= 2
    add_main_menu_option(:show_station_info, 'Показать поезда на станции')
    puts "Станция #{@stations.last} создана"
  end

  def add_train
    puts 'Введите номер нового поезда:'
    number = gets.to_i
    
    puts "Выберете тип поезда:\n1. Пассажирский\n2. Грузовой"
    choice = gets.to_i
    @trains << case choice
               when 1 then PassengerTrain.new(number)
               when 2 then CargoTrain.new(number)
               end

    add_main_menu_option(:manage_train, 'Управлять поездом')
    puts "#{@trains.last} создан."
  end
  
  def add_route
    departure_station = choose(@stations, 
                               question = 'Выберете станцию отправления:')
    destination_station = choose(@stations, 
                                 question = 'Выберете станцию назначения:')
    @routes << Route.new(departure_station, destination_station)

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
      puts "Сейчас на станции #{station} следующие поезда:\n" \
           "#{station.current_trains.join("\n")}"
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
    actions[:detach_wagon] = 'Отсоединить вагон' if train.wagons.any?

    if train.route
      actions[:go_to_next_station] = 'Поехать на следующую станцию'
      actions[:go_to_previous_station] = 'Поехать на предыдущую станцию'
    end

    choose_action(actions)
  end

  def process_route_action(route, action_key)
    case action_key
    when :add_intermediate_station
      stations_to_add = @stations - route.stations
      if stations_to_add.any?
        station = choose(stations_to_add, question = 'Выберете станцию:')
        route.add_intermediate_station(station)
        puts "Станция #{station} добавлена в маршрут."
      else
        puts 'Ошибка, нет станций, которые можно было бы добавить в маршрут.'
      end
    when :remove_intermediate_station
      stations_to_remove = route.stations[1...-1]
      if stations_to_remove.any?
        station = choose(stations_to_remove, question = 'Выберете станцию:')
        route.remove_intermediate_station(station)
        puts "Станция #{station} удалена из маршрута"
      else
        puts 'Ошибка, в маршруте нет промежуточных станций.'
      end
    end
  end

  def process_train_action(train, action_key)
    case action_key
    when :attach_wagon
      unless train.speed == 0
        puts 'Ошибка. Невозможно присоединить вагон, когда поезд движется.'
        return nil
      end

      if train.is_a? PassengerTrain
        train.attach_wagon(PassengerWagon.new)
        puts 'Пассажирский вагон прицеплен'
      elsif train.is_a? CargoTrain
        train.attach_wagon(CargoWagon.new)
        puts 'Грузовой вагон прицеплен'
      end
    when :detach_wagon 
      unless train.speed == 0
        puts 'Ошибка. Невозможно отсоединить вагон, когда поезд движется.'
        return nil
      end

      train.detach_wagon(train.wagons.last)
      puts 'Вагон отцеплен'
    when :assign_a_route
      if @routes.empty?
        puts 'Ошибка. Ни одного маршрута пока не создано.'
      else
        route = choose(@routes, question = 'Выберете маршрут:')
        train.assign_a_route(route)
        puts 'Маршрут назначен'
      end
    when :go_to_next_station
      if train.on_last_station?
        puts 'Ошибка, поезд на последней станции маршрута.'
      else
        train.go_to_next_station
        puts "Поезд прибыл на станцию #{train.current_station}"
      end
    when :go_to_previous_station
      if train.on_first_station?
        puts 'Ошибка, поезд на первой станции маршрута.'
      else
        train.go_to_previous_station
        puts "Поезд прибыл на станцию #{train.current_station}"
      end    
    end
  end
end
