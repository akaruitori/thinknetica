 
puts 'Добро пожаловать в программу по определению идеального веса!'
puts 'Для начала введите, пожалуйста, ваше имя:'
user_name = gets.chomp
puts 'Введите ваш рост в сантиметрах:'
user_height = gets.to_i

ideal_weight = user_height - 110

if ideal_weight > 0
  puts "#{user_name}, идеальный для вас вес: #{ideal_weight} кг."
else
  puts "#{user_name}, Ваш вес уже оптимален."
end