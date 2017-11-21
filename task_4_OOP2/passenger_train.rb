require_relative 'passenger_wagon'

class PassengerTrain < Train
  def attach_wagon(wagon)
    @wagons << wagon if wagon.is_a? PassengerWagon
  end

  def to_s
    'Пассажирский ' + super
  end
end
