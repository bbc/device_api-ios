# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevicename calls
    class IDeviceDiagnostics < Execution

      # Reboot the device
      def self.reboot(device_id)
        self.restart(device_id)
      end

      def self.restart(device_id)
        result = execute("idevicediagnostics restart -u #{device_id}")
      end

    end
  end
end
