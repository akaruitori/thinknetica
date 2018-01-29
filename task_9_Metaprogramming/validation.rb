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
  end
end
