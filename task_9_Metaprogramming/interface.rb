require_relative 'station'
require_relative 'train'
require_relative 'route'
require_relative 'passenger_train'
require_relative 'cargo_train'

class Interface
  attr_reader :main_menu

  def initialize
    @stations = []
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
    end
  end

  def choose_action(actions_hash,
                    question = 'Выберете действие:')
    action_texts = actions_hash.values
    choice = choose(action_texts, question)

    actions_hash.keys[choice]
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
    choice = choose(%w[Пассажирский Грузовой], 'Выберете тип поезда:')

    begin
      puts 'Введите номер нового поезда:'
      number = gets.chomp
      @trains << case choice
                 when 0 then PassengerTrain.new(number)
                 when 1 then CargoTrain.new(number)
                 end
    rescue RuntimeError => error_message
      puts error_message
      puts
      retry
    end

    add_main_menu_option(:manage_train, 'Управлять поездом')
    puts "#{@trains.last} создан."
  end

  def new_passenger_wagon
    puts 'Введите количество мест в вагоне.'
    seats_number = gets.to_i
    PassengerWagon.new(seats_number)
  rescue RuntimeError => error_message
    puts error_message
    puts
    retry
  end

  def new_cargo_wagon
    puts 'Укажите объем вагона в кубических метрах.'
    capacity = gets.to_i
    CargoWagon.new(capacity)
  rescue RuntimeError => error_message
    puts error_message
    puts
    retry
  end

  def add_route
    departure = @stations[choose(@stations, 'Выберете станцию отправления:')]
    destination = @stations[choose(@stations, 'Выберете станцию назначения:')]
    @routes << Route.new(departure, destination)
  rescue RuntimeError => error_message
    puts error_message
    puts
    retry
  ensure
    add_main_menu_option(:manage_route, 'Управлять маршрутом')
    puts "Маршрут #{@routes.last} создан."
  end

  def manage_route
    route = @routes[choose(@routes, 'Выберете маршрут:')]
    action_key = choose_route_action(route)
    process_route_action(route, action_key)
  end

  def manage_train
    train = @trains[choose(@trains, 'Выберете поезд:')]
    action_key = choose_train_action(train)
    process_train_action(train, action_key)
  end

  def show_station_info
    station = @stations[choose(@stations, 'Выберете станцию:')]

    if station.trains.empty?
      puts "На станции #{station} нет поездов"
    else
      puts "Сейчас на станции #{station} следующие поезда:"
      station.each_train { |train| puts train.to_s }
    end
  end

  private

  def choose(items, question = nil)
    if items.size == 1
      puts 'Автоматически выбран единственный объект.'
      return 0
    end

    puts question
    items.each_with_index { |item, i| puts "#{i + 1}. #{item}" }

    gets.to_i - 1
  end

  def add_main_menu_option(key, description)
    main_menu[key] = description unless main_menu.key?(key)
  end

  def choose_route_action(_route)
    actions = { add_intermediate_station: 'Добавить станцию',
                remove_intermediate_station: 'Удалить станцию' }
    choose_action(actions)
  end

  def choose_train_action(train)
    choose_action(gather_train_actions(train))
  end

  def gather_train_actions(train)
    actions = { attach_wagon: 'Прицепить вагон' }
    actions[:assign_a_route] = 'Назначить маршрут' if @routes.any?

    if train.wagons.any?
      actions[:detach_wagon] = 'Отсоединить вагон'
      actions[:show_all_wagons] = 'Посмотреть все вагоны'

      if train.is_a? PassengerTrain
        actions[:occupy_a_seat] = 'Занять место в вагоне'
      elsif train.is_a? CargoTrain
        actions[:fill_wagon] = 'Занять объем в вагоне'
      end
    end

    if train.route
      actions[:go_to_next_station] = 'Поехать на следующую станцию'
      actions[:go_to_previous_station] = 'Поехать на предыдущую станцию'
    end
    actions
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
      station = stations_to_add[choose(stations_to_add, 'Выберете станцию:')]
      route.add_intermediate_station(station)
      puts "Станция #{station} добавлена в маршрут."
    else
      puts 'Ошибка, нет станций, которые можно было бы добавить в маршрут.'
    end
  end

  def remove_intermediate_station(route)
    stations_to_remove = route.stations[1...-1]
    if stations_to_remove.any?
      station = stations_to_remove[
                choose(stations_to_remove, 'Выберете станцию:')
                ]
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
    when :fill_wagon then fill_wagon(train)
    end
  end

  def attach_wagon(train)
    unless train.speed.zero?
      puts 'Ошибка. Невозможно присоединить вагон, когда поезд движется.'
      return nil
    end

    if train.is_a? PassengerTrain
      train.attach_wagon(new_passenger_wagon)
      puts 'Пассажирский вагон прицеплен.'
    elsif train.is_a? CargoTrain
      train.attach_wagon(new_cargo_wagon)
      puts 'Грузовой вагон прицеплен.'
    end
  end

  def detach_wagon(train)
    unless train.speed.zero?
      puts 'Ошибка. Невозможно отсоединить вагон, когда поезд движется.'
      return nil
    end

    train.detach_wagon(train.wagons.last)
    puts 'Вагон отцеплен.'
  end

  def assign_a_route(train)
    route = @routes[choose(@routes, 'Выберете маршрут:')]
    train.assign_a_route(route)
    puts 'Маршрут назначен'
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
    wagon = train.wagons[choose(train.wagons, 'Выберете вагон:')]
    wagon.occupy_a_seat
    puts "Место занято, в вагоне осталось #{wagon.available_seats} "\
    'свободных мест.'
  rescue RuntimeError => error_message
    puts error_message
    puts
    retry
  end

  def fill_wagon(train)
    wagon = train.wagons[choose(train.wagons, 'Выберете вагон:')]
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
