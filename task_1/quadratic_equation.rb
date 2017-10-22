puts 'Добро пожаловать в программу для решения квадратных уравнений'

puts 'Введите коэффициент при х в квадрате:'
a = gets.to_f

puts 'А теперь при х:'
b = gets.to_f

puts 'И свободный член уравнения:'
c = gets.to_f

d = b**2 - 4 * a * c
puts "Дискриминант этого уравнения равен #{d}"
sqrt_d = Math.sqrt(d)

if d < 0
  puts 'Действительных корней нет.'
elsif d == 0
  puts "Есть один корень: #{ -b / (2 * a)}"
else
  puts "Корни уравнения: #{(-b + sqrt_d) / (2 * a)} и #{(-b - sqrt_d) / (2 * a)}"
end  
