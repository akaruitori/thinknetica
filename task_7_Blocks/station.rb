class Station
  attr_reader :trains

  @all = []

  class << self
    attr_accessor :all
  end

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

  private

  def validate!
    raise 'Название станции не может отсутствовать.' if @name.empty?
    raise 'Название слишком длинное.' if @name.length > 35
    true
  end

  def valid?
    validate!
  rescue StandardError
    false
  end
end
