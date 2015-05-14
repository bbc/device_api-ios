require 'device_api/device'
require 'device_api/ios/device'
require 'device_api/ios/idevice'
require 'ios/devices'

module DeviceAPI
  module IOS
    class Device < DeviceAPI::Device
      def initialize(options = {})
        @serial = options[:serial]
        @state = options[:state]
      end

      def status
        {
            'device' => :ok,
            'no device' => :dead,
            'offline' => :offline
        }[@state]
      end

      def model
        Ios::Devices.search(get_prop('ProductType')).name
      end

      def version
        get_prop('ProductVersion')
      end

      def device_class
        get_prop('DeviceClass')
      end

      def imei
        get_prop('InternationalMobileEquipmentIdentity')
      end

      def trusted?
        IDevice.trusted?(serial)
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