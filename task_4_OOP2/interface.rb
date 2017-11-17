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
# У инстансов классов Маршрут и Поезд есть свои хеши возможных действий, 
# про которые знает данный класс.

# Из всего зоопарка методов приватный только choose. Я думала сделать приватными
# все подметоды, так как они не вызываются извне. Но получала ошибку 
# вызова приватного метода. 
# Не понимаю, почему. В main.rb вызывается process_main_menu 
# с аргументом-символом, а подметоды по идее вызываются внутри класса Interface. 

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
    when :add_station then self.add_station
    when :add_train then self.add_train
    when :add_route then self.add_route
    when :manage_route then self.manage_route
    when :manage_train then self.manage_train
    when :show_station_info then self.show_station_info
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
    @stations << Station.from_user_input

    # Проверка, можно ли добавить в главное меню опцию создания маршрута
    if @stations.size >= 2 && !@main_menu.has_key?(:add_route)
      @main_menu[:add_route] = 'Добавить маршрут'
    end

    unless @main_menu.has_key?(:show_station_info)
      @main_menu[:show_station_info] = 'Показать поезда на станции'
    end
  end

  def add_train
    @trains << Train.from_user_input

    unless @main_menu.has_key?(:manage_train)
      @main_menu[:manage_train] = 'Управлять поездом'
    end
  end
  
  def add_route
    departure_station = choose(@stations, 
                               question = 'Выберете станцию отправления:')
    destination_station = choose(@stations, 
                                 question = 'Выберете станцию назначения:')
    
    @routes << Route.new(departure_station, destination_station)

    unless @main_menu.has_key?(:manage_route)
      @main_menu[:manage_route] = 'Управлять маршрутом'
    end
  end

  def manage_route
    route = choose(@routes, question = 'Выберете маршрут:')
    action = choose_action(route.actions, 
                           exit_option = false, 
                           question = 'Выберете действие с маршрутом:')

    # Определяет, какой список станций показать для добавления или удаления.
    stations = case action
               when :add_intermediate_station
                 @stations - route.stations
               when :remove_intermediate_station
                 route.stations[1...-1]
               end

    if stations.empty?
      puts 'Ошибка. Нет подходящих станций.'
      return nil
    end

    station = choose(stations, question = 'Выберете станцию:')
    route.process_action(action, station)
  end

  def manage_train
    train = choose(@trains, question = 'Выберете поезд:')
    action = choose_action(train.actions, 
                           exit_option = false, 
                           question = 'Выберете действие:')    

    if action == :assign_a_route && @routes.empty?
        puts 'Ошибка. Ни одного маршрута пока не создано.'
        return nil
    elsif action == :assign_a_route
      route = choose(@routes, question = 'Выберете маршрут:')
    end

    train.process_action(action, route)
  end

  def show_station_info
    station = choose(@stations, question = 'Выберете станцию:')
    puts station.info
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
end
