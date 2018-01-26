require_relative 'company_name'
require_relative 'instance_counter'
require_relative 'validation'
require_relative 'accessors'

class Train
  include CompanyName
  include InstanceCounter
  include Validation
  extend Accessors

  attr_reader :speed, :number, :route

  NUMBER_FORMAT = /^[a-zа-я\d]{3}-?[a-zа-я\d]{2}$/i

  validate :number, :presence
  validate :number, :format, NUMBER_FORMAT
  validate :namber, :type, String
 
  @all_by_number = {}

  class << self
    attr_accessor :all_by_number
  end

  def self.find(number)
    @all_by_number[number]
  end

  def initialize(number)
    @number = number
    @speed = 0
    @wagons = []

    validate!
    self.class.all_by_number[number] = self
    register_instance
  end

  def attach_wagon(wagon); end

  def detach_wagon(wagon)
    @wagons.delete(wagon)
  end

  def assign_a_route(route)
    current_station.depart(self) if @route

    @route = route
    @current_location_index = 0
    current_station.handle(self)
  end

  def go_to_next_station
    current_station.depart(self)
    @current_location_index += 1
    current_station.handle(self)
  end

  def go_to_previous_station
    current_station.depart(self)
    @current_location_index -= 1
    current_station.handle(self)
  end

  def on_first_station?
    @current_location_index.zero?
  end

  def on_last_station?
    @current_location_index == @route.stations.size - 1
  end

  def current_station
    @route.stations[@current_location_index] if @route
  end

  # def valid?
  #   validate!
  # rescue RuntimeError
  #   false
  # end

  def each_wagon
    @wagons.each { |wagon| yield(wagon, @wagons.index(wagon)) }
  end

  def to_s
    "Поезд № #{@number} (вагонов: #{@wagons.size})"
  end

  protected

  # def validate!
  #   raise 'Номер поезда не может отсутствовать.' if @number.empty?
  #   raise 'Неверно указан номер поезда.' if @number !~ NUMBER_FORMAT
  #   true
  # end

  def speed_up(additional_speed = 80)
    @speed += additional_speed
  end

  def brake
    @speed = 0
  end

  def previous_station
    return unless @current_location_index.zero?
    @route.stations[@current_location_index - 1]
  end

  def next_station
    return unless @current_location_index == @route.stations.size - 1
    @route.stations[@current_location_index + 1]
  end
end
