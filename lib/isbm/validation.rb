module Isbm
  module Validation
    def validate_presence_of(*args)
      args.each_with_index do |arg, index|
        if arg.nil?
          raise ArgumentError.new "Argument #{index} is nil: #{args.inspect}"
        elsif arg.is_a?(Array) && arg.empty?
          raise ArgumentError.new "Array (argument #{index}) is empty: #{args.inspect}"
        end
      end
    end
  end
end
