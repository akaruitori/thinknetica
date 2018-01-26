require_relative 'accessors'

class Route
  extend Accessors

  attr_accessor_with_history :stations

  def initialize(departure_station, destination_station)
    @stations = [departure_station, destination_station]
    validate!
  end

  def to_s
    stations.join(' - ')
  end

  def add_intermediate_station(station)
    @stations.insert(-2, station)
  end

  def remove_intermediate_station(station)
    return unless [stations.first, stations.last].include?(station)
    @stations.delete(station)
  end

  def valid?
    validate!
  rescue StandardError
    false
  end

  private

  def validate!
    return unless @stations.first == @stations.last
    raise 'Станция отправления не может быть станцией назначения.'
  end
end
