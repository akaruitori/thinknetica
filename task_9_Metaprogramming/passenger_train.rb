require_relative 'passenger_wagon'

class PassengerTrain < Train
  validate :number, :presence
  validate :number, :format, NUMBER_FORMAT
  validate :number, :type, String

  attr_accessor_with_history :wagons

  @all_by_number = {}

  def attach_wagon(wagon)
    @wagons << wagon if wagon.is_a? PassengerWagon
  end

  def to_s
    'Пассажирский ' + super
  end
end
