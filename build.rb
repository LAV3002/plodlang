# require_relative 'lib/devices/ns16550'
# require_relative 'lib/devices/test'

# require 'yaml'

# puts Plod::Lang::getDesc

# ir = Plod::Lang::toIR
# puts ir

# yaml_string = ir.to_yaml
# # puts yaml_string

# yaml_obj = YAML.safe_load(
#   yaml_string,
#   permitted_classes: [Symbol],
#   symbolize_names: true
# )
# # puts yaml_obj

# puts ir == yaml_obj

# dis_desc = Plod::Lang::fromIR(yaml_obj)
# # puts dis_desc

# puts Plod::Lang::getDesc == dis_desc
# 

# module Lang

# class ExprWrapper
#   def+(other)
#     puts "EW+"
#   end
# end

# end


# module TS

#   def self.ew 
#     return Lang::ExprWrapper.new()
#   end
# end


# def TF(&block)
#   TS.module_eval &block  
# end

# puts TS::ew

# TF {ew + ew}

# File.write('IR.yaml', Plod::Lang::toIR.to_yaml)
# 