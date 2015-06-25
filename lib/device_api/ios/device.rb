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

      private

      def get_prop(key)
        if !@props || !@props[key]
          @props = IDevice.get_props(serial)
        end
        @props[key]
      end

    end
  end
end