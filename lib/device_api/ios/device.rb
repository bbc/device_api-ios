require 'device_api/device'
require 'device_api/ios/device'
require 'device_api/ios/idevice'
require 'device_api/ios/idevicename'
require 'ios/devices'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for the Device object.
    class Device < DeviceAPI::Device
      def initialize(options = {})
        @serial = options[:serial]
        @state = options[:state]
      end

      # Mapping of device status - used to provide a consistent status across platforms
      # @return (String) common status string
      def status
        {
            'device' => :ok,
            'no device' => :dead,
            'offline' => :offline
        }[@state]
      end

      # Look up device name - i.e. Bob's iPhone
      # @return (String) iOS device name
      def name
        IDeviceName.name(serial)
      end

      # Look up device model using the ios-devices gem - changing 'iPad4,7' to 'iPad mini 3'
      # @return (String) human readable model and version (where applicable)
      def model
        Ios::Devices.search(get_prop('ProductType')).name
      end

      # Returns the devices iOS version number - i.e. 8.2
      # @return (String) iOS version number
      def version
        get_prop('ProductVersion')
      end

      # Return the device class - i.e. iPad, iPhone, etc
      # @return (String) iOS device class
      def device_class
        get_prop('DeviceClass')
      end

      # Get the IMEI number of the device
      # @return (String) IMEI number of current device
      def imei
        get_prop('InternationalMobileEquipmentIdentity')
      end

      # Has the 'Trust this device' dialog been accepted?
      # @return (Boolean) true if the device is trusted, otherwise false
      def trusted?
        IDevice.trusted?(serial)
      end

      # Get the IP Address from the device
      # @return [String] IP Address of current device
      def ip_address
        IPAddress.address(serial)
      end

      # Get the Wifi Mac address for the current device
      # @return [String] Mac address of current device
      def wifi_mac_address
        get_prop('WiFiAddress')
      end

      # Install a specified IPA
      # @param [String] ipa string containing path to the IPA to install
      # @return [Boolean, Exception] true when the IPA installed successfully, otherwise an error is raised
      def install(ipa)
        fail StandardError, 'No IPA or app specified.', caller if ipa.empty?

        res = install_ipa(ipa)

        fail StandardError, res, caller unless res
        true
      end

      # Uninstall a specified package
      # @param [String] package_name string containing name of package to uninstall
      # @return [Boolean, Exception] true when the package is uninstalled successfully, otherwise an error is raised
      def uninstall(package_name)
        res = uninstall_package(package_name)

        fail StandardError, res, caller unless res
        true
      end

      # Return whether or not the device is a tablet or mobile
      # @return [Symbol] :tablet or :mobile depending on device_class
      def type
        if device_class.downcase == 'ipad'
          :tablet
        else
          :mobile
        end
      end

      def list_installed_packages
        IDeviceInstaller.list_installed_packages(serial)
      end

      # Reboot the device
      def reboot
        restart
      end

      def restart
        IDeviceDiagnostics.reboot(serial)
      end

      private

      def get_prop(key)
        if !@props || !@props[key]
          @props = IDevice.get_props(serial)
        end
        @props[key]
      end

      def install_ipa(ipa)
        IDeviceInstaller.install_ipa(ipa: ipa, serial: serial)
      end

      def uninstall_package(package_name)
        IDeviceInstaller.uninstall_package(package: package_name, serial: serial)
      end
    end
  end
end
