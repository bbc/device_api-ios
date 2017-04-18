# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevicescreenshot calls
    class IDeviceScreenshot < Execution

      # Take a screenshot of the device based on the provided UUID
      # @param filename for the output file
      def self.capture(args)
        result = execute("idevicescreenshot #{args[:filename]} -u #{args[:device_id]}")
        raise IDeviceScreenshotError.new(result.stderr) if result.exit != 0
      end
    end

    # Error class for the IDeviceScreenshot class
    class IDeviceScreenshotError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
