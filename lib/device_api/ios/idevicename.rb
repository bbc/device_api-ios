# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevicename calls
    class IDeviceName < Execution

      # Returns the device name based on the provided UUID
      # @param device_id uuid of the device
      # @return device name if device is connected
      def self.name(device_id)
        result = execute("idevicename -u #{device_id}")
        return IDeviceNameError.new(result.stderr) if result.exit != 0
        result.stdout.strip
      end
    end

    # Error class for the IDeviceName class
    class IDeviceNameError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end