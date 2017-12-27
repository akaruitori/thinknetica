=begin
Создать модуль InstanceCounter, содержащий следующие методы класса 
и инстанс-методы, которые подключаются автоматически при вызове include
в классе:
  Методы класса:
    - instances, который возвращает кол-во экземпляров данного класса
  Инастанс-методы:
    - register_instance, который увеличивает счетчик кол-ва экземпляров 
    асса и который можно вызвать из конструктора. При этом данный метод 
    не должен быть публичным.
=end

module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def instances
      self.class_variable_get("@@instance_count")
    end
  end

  module InstanceMethods
    @@instance_count = 0

    protected

    def register_instance
      @@instance_count += 1
    end
  end  
end
