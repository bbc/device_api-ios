require 'device_api/ios/idevicedebug'
require 'device_api/ios/ideviceinstaller'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class IPAddress < Execution

      # Package name for the IP Address app
      def self.ipaddress_bundle_id
        'uk.co.bbc.titan.IPAddress'
      end

      # Check to see if the IPAddress app is installed
      # @param [String] serial serial of the target device
      # @return [Boolean] returns true if the app is installed
      def self.installed?(serial)
        if DeviceAPI::IOS::IDeviceInstaller.package_installed?( serial: serial, package: ipaddress_bundle_id )
          return true
        else
          warn IPAddressError.new('IP Address package not installed: Please see https://github.com/bbc/ios-test-helper')
        end
      end

      # Get the IP Address from the installed app
      # @param [String] serial serial of the target device
      # @return [String] IP Address if found
      def self.address(serial)
        return nil unless installed?(serial)
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

    # Error class for the IPAddress class
    class IPAddressError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end