require 'device_api/execution'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class IDevice < Execution

      # Returns an array of hashes representing connected devices
      # @return (Array) Hash containing serial and device name
      def self.devices
        result = execute_with_timeout_and_retry('idevice_id -l')

        raise IDeviceCommandError.new(result.stderr) if result.exit != 0

        lines = result.stdout.split("\n")
        results = []

        lines.each do |ln|
          if /[0-9a-zA-Z].*/.match(ln)
            results.push(ln => execute_with_timeout_and_retry("ideviceinfo -u #{ln} -k DeviceName").stdout.split("\n"))
          end
        end
        results
      end

      # Check to see if device has trusted the computer
      # @param device_id uuid of the device
      # @return true if the device returns information to ideviceinfo, otherwise false
      def self.trusted?(device_id)
        result = execute("ideviceinfo -u '#{device_id}'")

        return true if result.exit == 0 && !result.stdout.split("\n")[0].match('Usage')
        false
      end

      # Returns a Hash containing properties of the specified device using idevice_id.
      # @param device_id uuid of the device
      # @return (Hash) key value pair of properties
      def self.get_props(device_id)
        result = execute("ideviceinfo -u '#{device_id}'")

        raise IDeviceCommandError.new(result.stderr) if result.exit != 0

        result = result.stdout
        props = {}
        unless result.start_with?('Usage:')
          prop_list = result.split("\n")
          prop_list.each do |line|
            matches = line.scan(/(.*): (.*)/)
            prop_name, prop_value = matches[0]
            props[prop_name.strip] = prop_value.strip
          end
        end

        props
      end
    end

    # Exception class to handle exceptions related to IDevice Class
    class IDeviceCommandError < StandardError
      def initialize(msg)
        super(msg)
      end
    end

  end
end