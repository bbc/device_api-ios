require 'yaml'

module DeviceAPI
  config_file = '../../config.yml'
  self.CONFIG = YAML.load_file(File.expand_path(config_file, __FILE__))
end
