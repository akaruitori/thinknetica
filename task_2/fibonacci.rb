=begin
Заполнить массив числами фибоначчи до 100
=end

fibonacci = [1, 2]

while (next_element = fibonacci[-2..-1].sum) < 100
  fibonacci << next_element
end

puts fibonacci
