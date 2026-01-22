require_relative 'lib/devices/ns16550'
require_relative 'lib/devices/test'

require 'yaml'

puts Plod::Lang::toIR

yaml_string = Plod::Lang::toIR.to_yaml
puts yaml_string

puts YAML.safe_load(
  yaml_string,
  permitted_classes: [Symbol],
  symbolize_names: true
)

# File.write('IR.yaml', Plod::Lang::toIR.to_yaml)