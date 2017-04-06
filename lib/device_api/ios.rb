require 'yaml'
require 'device_api/ios/device'
require 'device_api/ios/idevice'
require 'device_api/ios/ideviceinstaller'
require 'device_api/ios/idevicedebug'
require 'device_api/ios/ipaddress'
require 'device_api/ios/ideviceprovision'
require 'device_api/ios/idevicename'

module DeviceAPI
  module IOS

    # Returns an array of connected iOS devices
    def self.devices
      devs = IDevice.devices
      devs.keys.map do |serial|
        DeviceAPI::IOS::Device.new(serial: serial, display: devs[serial], state: 'ok')
      end
    end

    # Retrieve a Device object by serial ID
    def self.device(serial)
      if serial.to_s.empty?
        raise DeviceAPI::BadSerialString.new("Serial was '#{ serial.nil? ? 'nil' : serial }'")
      end
      DeviceAPI::IOS::Device.new(serial: serial, state: 'device')
    end
  end
end
