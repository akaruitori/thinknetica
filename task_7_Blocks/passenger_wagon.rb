class PassengerWagon
  include CompanyName

  attr_reader :occupied_seats

  def initialize(seats_number)
    @seats_number = seats_number
    validate!

    @occupied_seats = 0
  end

  def validate!
    return if (1..100).cover?(@seats_number)
    raise 'В вагоне может быть от 1 до 100 мест'
  end

  def occupy_a_seat
    raise 'Все места в вагоне заняты.' if @occupied_seats == @seats_number
    @occupied_seats += 1
  end

  def available_seats
    @seats_number - @occupied_seats
  end

  def to_s
    "Пассажирский вагон, всего мест: #{@seats_number}, " \
    "свободно мест: #{available_seats}."
  end
end
