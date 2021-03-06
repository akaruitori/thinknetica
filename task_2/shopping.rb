=begin
Сумма покупок. Пользователь вводит поочередно название товара, цену за единицу 
и кол-во купленного товара (может быть нецелым числом). Пользователь может 
ввести произвольное кол-во товаров до тех пор, пока не введет "стоп" в качестве 
названия товара. На основе введенных данных требуетеся:
  Заполнить и вывести на экран хеш, ключами которого являются названия товаров, 
   а значением - вложенный хеш, содержащий цену за единицу товара и кол-во 
   купленного товара. Также вывести итоговую сумму за каждый товар.
  Вычислить и вывести на экран итоговую сумму всех покупок в "корзине".
=end

def add_to_cart(product, cart)
  puts "Введите цену товара #{product}:"
  price = gets.to_f
  puts 'Сколько единиц берём?'
  amount = gets.to_f
  cart[product] = {price: price, amount: amount}
end

cart = {}
total_cost = 0

loop do
  puts 'Введите название продукта, чтобы купить его, или стоп, чтобы '\
  'закончить покупки.'
  product = gets.chomp
  break if product.downcase == 'стоп'
  add_to_cart(product, cart)
end

puts "Хеш с покупками: #{cart}"
puts 'Сумма за каждую покупку:'

cart.each do |product, info| 
  cost = (info[:price] * info[:amount]).round(2)
  puts "#{product}..... #{cost} руб."
  total_cost += cost
end

puts "Итоговая стоимость покупок: #{total_cost} руб."
