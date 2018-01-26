module Validation
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    attr_accessor :validation_list

    def validations(type, *args)
      case type
      when :presence then [['!=', nil], ['!=', '']]
      when :format then [['=~', args.first]]
      when :type then [['is_a?', args.first]]
      end
    end

    def validation_error_messages(type, *args)
      case type
      when :presence then 'should be present'
      when :format then 'has incorrect format'
      when :type then "should be an instance of #{args.first}"
      end
    end

    def validate(attr_name, type, *args)
      @validation_list ||= []
      @validation_list << ["validate_#{attr_name}_#{type}", args]
    end
  end

  module InstanceMethods
    def validate!
      # Вызывается в конструкторе.
      # Берет сформированный список названий методов валидиций в формате
      # validate_attribute_type, и каждый метод вместе с аргументом передает 
      # в send
      self.class.validation_list.each do |validation|
        val_method = validation.first
        args = validation.last if validation.size == 2
        send(val_method, *args)
      end

      raise error_message if @validation_errors.any?
    end

    def valid?
      validate!
      @validation_errors.none?
    end

    def method_missing(sym, *args)
      pattern = /^validate_([a-z]{1,20})_([a-z]{1,20})$/
      pattern_match = pattern.match(sym)

      super(sym, *args) unless pattern_match

      attr_name = pattern_match[1].to_sym
      type = pattern_match[2].to_sym

      make_validation(attr_name, type, *args)
    end

    def make_validation(attr_name, type, *args)
      attribute = instance_variable_get("@#{attr_name}".to_sym)
      @validation_errors ||= Hash.new { |h, k| h[k] = [] }

      # Двухмерный массив методов и аргументов для валидаций:
      validation_methods = self.class.validations(type, *args)
   
      validation_methods.each do |method_and_argument|
        validation_method, argument = method_and_argument

        # Если проверка вернет false, в хеш ошибок добавится сообщение, 
        # какая проверка не прошла. Потом по этому хешу проверяется, есть ли
        # непройденные валидации, и из него же берется сообщения для вывода.
        unless attribute.send(validation_method, argument)
          @validation_errors[attr_name] << 
            self.class.validation_error_messages(type, argument)
        end
      end
    end

    def error_message
      error_message = ''
      @validation_errors.each do |attr_name, validation_errors|
        error_message += 
          "#{attr_name.capitalize} #{validation_errors.join(', ')}. "
      end
      error_message
    end
  end
end
