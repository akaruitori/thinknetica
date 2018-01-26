require_relative 'validation'
require_relative 'accessors'

class Station
  include Validation
  extend Accessors

  class << self
    attr_accessor :all
  end
  attr_accessor_with_history :trains, :name

  @all = []

  NAME_FORMAT = /^[a-zа-я\d ]{2,35}$/i

  validate :name, :presence
  validate :name, :format, NAME_FORMAT
  validate :name, :type, String

  def initialize(name)
    @name = name
    @trains = []

    validate!
    self.class.all << self
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

  def current_trains(type = :all)
    return @trains if type == :all
    @trains.select { |train| train.type == type }
  end

  def total_trains(type = :all)
    current_trains(type).size
  end

  def each_train
    current_trains.each { |train| yield(train) }
  end
end
