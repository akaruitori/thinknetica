require_relative 'cargo_wagon'

class CargoTrain < Train
  def initialize(number)
    super
    puts "Грузовой поезд № #{@number} создан."
  end

  def process_action(action, route = nil)
    super
    self.attach_wagon(CargoWagon.new) if action == :attach_wagon 
  end

  def attach_wagon(wagon)
    super
    @wagons << wagon if wagon.is_a? CargoWagon
    puts 'Грузовой вагон прицеплен'
  end

  def to_s
    'Грузовой ' + super
  end
end
