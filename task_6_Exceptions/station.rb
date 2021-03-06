=begin
Класс Station (Станция):
Имеет название, которое указывается при ее создании
Может принимать поезда (по одному за раз)
Может возвращать список всех поездов на станции, находящиеся в текущий момент
Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, 
  пассажирских
Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка 
  поездов, находящихся на станции).
=end

class Station
  require_relative 'company_name'

  attr_reader :trains

  @@all = []

  def self.all
    @@all
  end

  def initialize(name)
    @name = name
    @trains = []

    validate!
    @@all << self
  end

  def to_s
    @name
  end

  def handle(train)
    @trains << train
  end

  def depart(train)
    @trains.delete(train)
  end
  
  def current_trains(type=:all)
    return @trains if type == :all
    @trains.select { |train| train.type == type }
  end

  def total_trains(type=:all)
    current_trains(type).size
  end

  private

  def validate!
    raise 'Название станции не может отсутствовать.' if @name.empty?
    raise 'Название слишком длинное.' if @name.length > 35
    true
  end

  def valid?
    validate!
  rescue
    false
  end
end
