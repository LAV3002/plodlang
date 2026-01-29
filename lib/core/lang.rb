module Plod
  module Utils
    @@primitiveTypes = [Integer, String]

    def self.isPrimitive(value)
      @@primitiveTypes.any? { |type| value.is_a?(type) }
    end

    def self.isKey(hash, key)
      if hash.key?(:key)
        raise key + " field missed in IR"
      end
    end

    def self.toIR(value)
      if value.is_a?(Array)
        return value.map { |element| Utils::toIR(element) }
      elsif value.is_a?(Hash)
        return value.transform_values { |element| Utils::toIR(element) }
      elsif value.is_a?(Symbol)
        return value
      elsif isPrimitive(value)
        return value
      elsif value.nil?
        return nil
      else
        return value.toIR
      end
    end

    def self.BaseInfo(*fields)
      Class.new(Struct.new(*fields)) do
        def toIR
          hash = {}
          self.each_pair do |name, value|
            hash[name.to_sym] = Utils::toIR(value)
          end

          return hash
        end
      end
    end

    def self.fromDescIR(value)
      if !value.is_a?(Hash)
        raise "Invalid IR instance" 
      end

      desc = {}
      value.each do |key, section|
        if key == :device_sect
          desc[:device_sect] = Utils::fromDeviceIR(section)
        end
      end

      return desc
    end

    def self.fromDeviceIR(value)
      if !value.is_a?(Array)
        raise "Invalid device section IR instance"
      end

      sect = []
      value.each do |device|
        Utils::isKey(device, :name)
        Utils::isKey(device, :reg_sect)

        info = Lang::DeviceInfo.new(device[:name])
        info.reg_sect = Utils::fromRegIR(device[:reg_sect])

        sect << info
      end

      return sect
    end

    def self.fromRegIR(value)
      if !value.is_a?(Array)
        raise "Invalid device section IR instance"
      end

      sect = []
      value.each do |reg|
        Utils::isKey(reg, :name)
        Utils::isKey(reg, :size)
        Utils::isKey(reg, :offset)
        Utils::isKey(reg, :type)

        info = Lang::RegInfo.new(reg[:name])
        info.size = reg[:size]
        info.offset = reg[:offset]
        info.type = reg[:type]

        sect << info
      end

      return sect
    end
  end

  module Lang

    @@desc = {
      device_sect: []
    }

    @@semaBank = []

    def self.getDesc
      return @@desc
    end

    def self.toIR
      Utils::toIR(@@desc)
    end

    def self.fromIR(ir)
      Utils::fromDescIR(ir)
    end

    class DeviceInfo < Utils::BaseInfo(:name, :reg_sect)
      def initialize(name)
        super(name, [])
      end
    end

    class RegInfo < Utils::BaseInfo(:name, :size, :offset, :type)
      def initialize(name)
        super(name, nil, nil)
      end
    end

    class RegBuilder
      attr_accessor :info
      def initialize(name)
        @info = RegInfo.new(name)
      end

      def size(value)
        @info.size = value
      end

      def offset(value)
        @info.offset = value
      end

      def type(value)
        @info.type = value
      end
    end

    class DeviceBuilder
      attr_accessor :info
      def initialize(name)
        @info = DeviceInfo.new(name)
      end

      def Register(name, &block)
        regBuilder = RegBuilder.new(name)
        regBuilder.instance_eval &block
        @info.reg_sect << regBuilder.info
        nil
      end
    end

    def Device(name, &block)
      deviceBuilder = DeviceBuilder.new(name)
      deviceBuilder.instance_eval &block
      @@desc[:device_sect] << deviceBuilder.info
      nil
    end

    class Oper
      attr_accessor :kind, :opds
      
      def initialize(kind, opds)
        @kind = kind
        @opds = opds
      end
    end

    class ConstExpr
      attr_accessor :type, :kind, :value

      def initialize(type, value)
        @type = type
        @kind = :const
        @value = value
      end
    end

    class VarExpr
      attr_accessor :type, :kind, :name

      def initialize(type, name)
        @type = type
        @kind = :var
        @value = name
      end
    end

    class ExprWrapper
      attr_accessor :expr

      class << self
        attr_accessor :currentScope
      end
      
      @tmpCounter = 0
      @currentScope = nil

      def initialize(expr)
        @expr = expr
      end

      def self.setScope(scope)
        @currentScope = scope
      end

      def self.binOp(lhs, rhs, kind, retType = nil)
        if lhs.type != rhs.type
          raise "Bad bin op args"
        end

        if retType.nil?
          retType = lhs.type
        end

        var = VarExpr(retType, "tmp_#{@tmpCounter}".to_sym)
        @tmpCounter += 1

        @currentScope < Oper(kind, var, lhs.expr, rhs.expr)

        return var
      end
      
      def+(other); binOp(self, other, :add); end
      def-(other); binOp(self, other, :sub); end
      def<<(other); binOp(self, other, :shl); end
      def<(other); binOp(self, other, :lt, bv(1)); end
      def>(other); binOp(self, other, :gt, bv(1)); end
      def^(other); binOp(self, other, :xor); end
      def>>(other); binOp(self, other, :shr); end
      def|(other); binOp(self, other, :or) end
      def&(other); binOp(self, other, :and) end
      def==(other); binOp(self, other, :eq, bv(1)); end
      def!=(other); binOp(self, other, :ne, bv(1)); end
      # def[](r, l); @scope.extract(self, r, l); end

    end
  end

  module Scop
    
  end
end
