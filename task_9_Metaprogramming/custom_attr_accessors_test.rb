require_relative 'accessors'
require_relative 'station'
require_relative 'train'
require_relative 'passenger_train'

station_a = Station.new('Station A')

puts station_a.name
station_a.name = 'North A'
station_a.name = 'South A'

puts 'Station_a name history:'
puts station_a.name_history
puts

train_b = PassengerTrain.new('12323')
train_c = PassengerTrain.new('25251')

station_a.trains = [train_b]
puts station_a.trains

station_a.handle(train_c)
station_a.trains = [train_c]

puts 'Station_a trains history:'
puts station_a.trains_history
puts

wagon_d = PassengerWagon.new(25)
puts wagon_d.seats_number
wagon_d.seats_number = 30

begin
  wagon_d.seats_number = '25'
rescue TypeError => error_message
  puts error_message
end

