require 'device_api/execution'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class IDeviceInstaller < Execution
      def self.install_ipa(options = {})
        ipa = options[:ipa]
        serial = options[:serial]
        result = execute("ideviceinstaller -u '#{serial}' -i '#{ipa}'")

        raise IDeviceInstallerError.new(result.stderr) if result.exit != 0

        lines = result.stdout.split("\n").map { |line| line.gsub('-','').strip }

        lines.last
      end

      def self.uninstall_package(options = {})
        package = options[:package]
        serial = options[:serial]
        result = execute("ideviceinstaller -u '#{serial}' -U '#{package}'")

        raise IDeviceInstallerError.new(result.stderr) if result.exit != 0

        lines = result.stdout.split("\n").map { |line| line.gsub('-', '').strip }

        lines.last
      end
    end

    class IDeviceInstallerError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end