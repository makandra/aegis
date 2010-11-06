module Aegis
  class Util
    class << self

      def define_class_method(object, method, &body)
        prototype = object.respond_to?(:singleton_class) ? object.singleton_class : object.metaclass
        prototype.send(:define_method, method, &body)
      end

    end
  end
end