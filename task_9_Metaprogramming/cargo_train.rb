require_relative 'cargo_wagon'

class CargoTrain < Train
  validate :number, :presence
  validate :number, :format, NUMBER_FORMAT
  validate :number, :type, String

  @all_by_number = {}

  def attach_wagon(wagon)
    @wagons << wagon if wagon.is_a? CargoWagon
  end

  def to_s
    'Грузовой ' + super
  end
end
