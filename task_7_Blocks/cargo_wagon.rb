class CargoWagon
  include CompanyName

  def initialize(capacity)
    @capacity = capacity
    validate!

    @filled_volume = 0
  end

  def validate!
    return if (50..150).cover?(@capacity)
    raise 'Объем может составлять от 50 до 150 м³.'
  end

  def fill_wagon(volume)
    if @filled_volume + volume > @capacity
      raise "#{volume} м³ не поместится в вагон, можно занять не более " \
      "#{available_volume} м³."
    end
    @filled_volume += volume
  end

  def available_volume
    @capacity - @filled_volume
  end

  def to_s
    "Грузовой вагон, общий объем: #{@capacity} м³, " \
    "свободно: #{available_volume} м³."
  end
end
