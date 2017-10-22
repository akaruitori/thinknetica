puts 'Сейчас мы определим, прямоугольный ли ваш треугольник.'
triangle_sides = []

puts 'Введите длину первой стороны:'
triangle_sides << gets.to_f
puts 'А теперь второй:'
triangle_sides << gets.to_f
puts 'И третьей:'
triangle_sides << gets.to_f

triangle_sides.sort!
hypotenuse = triangle_sides.pop
cathetus_a = triangle_sides[0]
cathetus_b = triangle_sides[1]
 
if hypotenuse**2 == cathetus_a**2 + cathetus_b**2
  puts 'Ваш треугольник -- прямоугольный!'
  puts 'А также равнобедренный.' if cathetus_a == cathetus_b
else
  puts 'Этот треугольник не является прямоугольным.'  
end
