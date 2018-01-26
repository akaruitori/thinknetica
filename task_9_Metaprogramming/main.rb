require_relative 'interface'

interface = Interface.new

loop do
  main_menu = interface.main_menu
  choosed_action = interface.choose_action(main_menu)
  interface.process_main_menu(choosed_action)
  sleep(1)
  puts
end
