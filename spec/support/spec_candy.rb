# Abbreviated from http://makandra.com/notes/627-the-definitive-spec_candy-rb-rspec-helper

Object.class_eval do

  # a should receive that executes the expected method as usual. does not work with and_return
  def should_receive_and_execute(method)
    method_called = "_#{method}_called"

    prototype = respond_to?(:singleton_class) ? singleton_class : metaclass
    prototype.class_eval do
      define_method method do |*args|
        send(method_called, *args)
        super
      end
    end

    should_receive(method_called)
  end

end
