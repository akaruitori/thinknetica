=begin
Заполнить хеш гласными буквами, где значением будет являтся порядковый номер 
буквы в алфавите (a - 1).
=end

letters = 'абвгдеёжзийклмнопрстуфхцчшщьыъэюя'
vowels = {}

letters.each_char do |letter|
  vowels[letter] = letters.index(letter) + 1 if 'аеёиоуыэюя'.include?(letter)
end

puts vowels
