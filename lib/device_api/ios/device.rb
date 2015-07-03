require 'device_api/device'
require 'device_api/ios/device'
require 'device_api/ios/idevice'
require 'device_api/ios/plistutil'
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

      # Get the app bundle ID from the specified app
      # @return [String] app bundle id
      def package_name(app)
        app_info = Plistutil.get_bundle_id_from_app(app)
        app_info['CFBundleIdentifier']
      end

      # Get the app version from the specified app
      # @return [String] app version
      def app_version_number(app)
        app_info = Plistutil.get_bundle_id_from_app(app)
        app_info['CFBundleVersion']
      end

      # Install a specified IPA
      # @param [String] ipa string containing path to the IPA to install
      # @return [Symbol, Exception] :success when the IPA installed successfully, otherwise an error is raised
      def install(ipa)
        fail StandardError, 'No IPA or app specified.', caller if ipa.empty?

        res = install_ipa(ipa)

        case res
          when 'Complete'
            :success
          else
            fail StandardError, res, caller
        end
      end

      # Uninstall a specified package
      # @param [String] package_name string containing name of package to uninstall
      # @return [Symbol, Exception] :success when the package is uninstalled successfully, otherwise an error is raised
      def uninstall(package_name)
        res = uninstall_package(package_name)

        case res
          when 'Complete'
            :success
          else
            fail StandardError, "Unable to uninstall '#{package_name}'. Error reported: #{res}", caller
        end
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