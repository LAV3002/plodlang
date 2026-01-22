require_relative "../core/lang"

module Devices 
  include Plod::Lang
  extend Plod::Lang

  Device(:test) {
    Register(:t800) {
      size 0x1000
      offset 0x8888
    }
  }
end
