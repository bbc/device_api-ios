Gem::Specification.new do |s|
  s.name        = 'device_api-ios'
  s.version     = '1.1.0'
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = 'IOS Device Management API'
  s.description = 'iOS implementation of DeviceAPI'
  s.authors     = ['BBC', 'Jon Wilson', 'Kedar Barde']
  s.email       = ['jon.wilson01@bbc.co.uk', 'kedar_barde@mindtree.com']
  s.files       = `git ls-files`.split "\n"
  s.homepage    = 'https://github.com/bbc/device_api-ios'
  s.license     = 'MIT'
  s.add_runtime_dependency 'device_api', '>=1.0', '<2.0'
  s.add_runtime_dependency 'ios-devices', '>=0.2'
  s.add_runtime_dependency 'ox', '>=2.1.0'
  s.add_development_dependency 'rspec', '~> 3.5'
end
