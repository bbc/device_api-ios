require 'yaml'
require 'device_api/ios/device'
require 'device_api/ios/idevice'

module DeviceAPI
  module IOS

    def self.devices
      IDevice.devices.map do |d|
        if d.keys.first
          DeviceAPI::IOS::Device.new(serial: d.keys.first, display: d.values.flatten.first, state: 'ok', type: 'Device')
        end
      end
    end
  end
end