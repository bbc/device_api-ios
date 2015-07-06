require 'device_api/ios/idevicedebug'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class IPAddress < Execution

      def self.ipaddress_bundle_id
        'uk.co.bbc.titan.IPAddress'
      end

      def self.installed?(serial)
        if DeviceAPI::IOS::IDeviceInstaller.package_installed?( serial: serial, package: ipaddress_bundle_id )
          return true
        else
          raise IPAddressError.new('IP Address package not installed: Please see https://github.com/bbc/ios-test-helper')
        end
      end

      def self.address(serial)
        installed?(serial)
        result = IDeviceDebug.run(serial: serial, bundle_id: ipaddress_bundle_id )

        ip_address = nil
        result.each do |line|
          if /"en0\/ipv4" = "(.*)"/.match(line)
            ip_address = Regexp.last_match[1]
          end
        end
        ip_address
      end
    end

    class IPAddressError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end