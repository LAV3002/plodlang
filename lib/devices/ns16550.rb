require_relative "../core/lang"

module Devices 
  include Plod::Lang
  extend Plod::Lang

  Device(:ns16550) {
    Register(:lsr) {
      size 0x1
      offset 0x0
    }
  }
end
