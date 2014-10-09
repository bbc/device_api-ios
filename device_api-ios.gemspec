Gem::Specification.new do |s|
  s.name        = 'device_api-ios'
  s.version     = '0.0.1'
  s.date        = '2014-10-09'
  s.summary     = 'IOS Device Management API'
  s.description = 'A common interface for ios devices/Simulators'
  s.authors     = ['Kedar Barde']
  s.email       = 'kedar_barde@mindtree.com'
  s.files       = `git ls-files`.split "\n"
  s.homepage    = 'https://github.com/bbc-test/device_api-ios'
  s.license     = 'MIT'
  s.add_runtime_dependency 'device_api', '>=1.0'
  s.add_development_dependency 'rspec'
end
