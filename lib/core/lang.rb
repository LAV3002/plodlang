module Plod
  module Utils
    @@primitiveTypes = [Integer, String]

    def self.isPrimitive(value)
      @@primitiveTypes.any? { |type| value.is_a?(type) }
    end

    def self.toIR(value)
      if value.is_a?(Array)
        return value.map { |element| element.toIR }
      elsif value.is_a?(Symbol)
        return value
      elsif isPrimitive(value)
        return value
      else
        return value.toIR
      end
    end

    class BaseInfo
      def toIR
        hash = {}
        self.instance_variables.each do |var|
          hash[var[1..].to_sym] = Utils::toIR(self.instance_variable_get(var))
        end

        return hash
      end
    end
  end

  module Lang
    @@devices = []

    def self.toIR
      hash = {}
      hash[:devices] = Utils::toIR(@@devices)
      return hash
    end

    class DeviceInfo < Utils::BaseInfo
      attr_accessor :name, :registers

      def initialize(name)
        @kind = :device
        @name = name
        @registers = []
      end
    end

    class RegisterInfo < Utils::BaseInfo
      attr_accessor :name, :size, :offset

      def initialize(name)
        @kind = :register
        @name = name
        @size = nil
        @offset = nil
      end
    end

    class RegisterBuilder
      attr_accessor :info
      def initialize(name)
        @info = RegisterInfo.new(name)
      end

      def size(value)
        @info.size = value
      end

      def offset(value)
        @info.offset = value
      end
    end

    class DeviceBuilder
      attr_accessor :info
      def initialize(name)
        @info = DeviceInfo.new(name)
      end

      def Register(name, &block)
        registerBuilder = RegisterBuilder.new(name)
        registerBuilder.instance_eval &block
        @info.registers << registerBuilder.info
        nil
      end
    end

    def Device(name, &block)
      deviceBuilder = DeviceBuilder.new(name)
      deviceBuilder.instance_eval &block
      @@devices << deviceBuilder.info
      nil
    end

  end
end
