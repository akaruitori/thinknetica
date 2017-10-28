require_relative 'station'
require_relative 'route'
require_relative 'train'

stations = []
10.times { |i| stations << Station.new("Station #{i}") }

route_1 = Route.new(stations[0], stations[6])
route_2 = Route.new(stations[0], stations[9])

6.times { |i| route_1.add_intermediate_station(stations[i + 1]) }
route_1.remove_intermediate_station(stations[6])
puts "Маршрут 1: #{route_1}"
puts "Маршрут 2: #{route_2}"
puts

3.times do |i| 
  train_1 = Train.new("#{i}", :passenger, i + 5)
  train_2 = Train.new("2#{i}", :freight, i + 1)
  train_1.assign_a_route(route_1)
  train_2.assign_a_route(route_2)
  train_1.attach_wagon
  puts "Сейчас на станции #{stations[0]} следующие поезда:\n" \
     "#{stations[0].current_trains}"
  6.times { train_1.go_to_next_station }
  train_1.go_to_previous_station
  train_2.detach_wagon
  train_2.go_to_next_station
  puts train_1.info
  puts
  puts train_2.info
  puts
end

puts "Сейчас на станции #{stations[5]} пассажирских поездов: " \
     "#{stations[5].total_trains(:passenger)}.\n" \
     "#{stations[5].current_trains(type = :passenger)}"

puts     
puts "Сейчас на станции #{stations[9]} грузовых поездов: " \
     "#{stations[9].total_trains(:freight)}.\n" \
     "#{stations[9].current_trains(type = :freight)}"
