require_relative 'passenger_wagon'

class PassengerTrain < Train
  def initialize(number)
    super
    puts "Пассажирский поезд № #{@number} создан."
  end

  def process_action(action, route = nil)
    super
    self.attach_wagon(PassengerWagon.new) if action == :attach_wagon 
  end

  def attach_wagon(wagon)
    super
    @wagons << wagon if wagon.is_a? PassengerWagon
    puts 'Пассажирский вагон прицеплен'
  end

  def to_s
    'Пассажирский ' + super
  end
end
