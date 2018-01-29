module Validation
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    attr_accessor :validation_list

    def validate(attr_name, type, *args)
      @validation_list ||= []
      @validation_list << [attr_name, "validate_#{type}", args]
    end
  end

  module InstanceMethods

    def validate!
      @validation_errors ||= []

      self.class.validation_list.each do |validation|        
        attr_name, method_name, args = validation
        attr = instance_variable_get("@#{attr_name}")

        if validation_error = send(method_name, attr, *args)
          @validation_errors << "#{attr_name.capitalize} #{validation_error}."
        end
      end
      
      raise error_message if @validation_errors.any?
    end

    def valid?
      validate!
      @validation_errors.none?
    end

    private

    def validate_presence(attr)
      'should be present' if attr.nil? || attr == ''
    end

    def validate_format(attr, pattern)
      'has incorrect format' unless attr =~ pattern
    end

    def validate_type(attr, klass)
      "should be an instance of #{klass}" unless attr.is_a?(klass)
    end

    def error_message
      @validation_errors.join(' ')
    end



    # def validate!
    #   # Вызывается в конструкторе.
    #   # Берет сформированный список названий методов валидиций в формате
    #   # validate_attribute_type, и каждый метод вместе с аргументом передает 
    #   # в send
    #   self.class.validation_list.each do |validation|
    #     val_method = validation.first
    #     args = validation.last if validation.size == 2
    #     send(val_method, *args)
    #   end

    #   raise error_message if @validation_errors.any?
    # end



    # def method_missing(sym, *args)
    #   pattern = /^validate_([a-z]{1,20})_([a-z]{1,20})$/
    #   pattern_match = pattern.match(sym)

    #   super(sym, *args) unless pattern_match

    #   attr_name = pattern_match[1].to_sym
    #   type = pattern_match[2].to_sym

    #   make_validation(attr_name, type, *args)
    # end

    # def make_validation(attr_name, type, *args)
    #   attribute = instance_variable_get("@#{attr_name}".to_sym)
    #   @validation_errors ||= Hash.new { |h, k| h[k] = [] }

    #   # Двухмерный массив методов и аргументов для валидаций:
    #   validation_methods = self.class.validations(type, *args)
   
    #   validation_methods.each do |method_and_argument|
    #     validation_method, argument = method_and_argument

    #     # Если проверка вернет false, в хеш ошибок добавится сообщение, 
    #     # какая проверка не прошла. Потом по этому хешу проверяется, есть ли
    #     # непройденные валидации, и из него же берется сообщения для вывода.
    #     unless attribute.send(validation_method, argument)
    #       @validation_errors[attr_name] << 
    #         self.class.validation_error_messages(type, argument)
    #     end
    #   end
    # end


  end
end
