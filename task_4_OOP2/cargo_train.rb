require_relative 'cargo_wagon'

class CargoTrain < Train
  def attach_wagon(wagon)
    @wagons << wagon if wagon.is_a? CargoWagon
  end

  def to_s
    'Грузовой ' + super
  end
end
