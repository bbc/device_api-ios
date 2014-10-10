# Encoding: utf-8
#@author Kedar Barde

# This class provides the basis behaviour of ios devices (not simulators currently)

require 'device_api/device'
require 'device_api/ios/idevice'
require 'device_api/ios/simulator'

module DeviceAPI
  module IOS
    class Device < DeviceAPI::Device

      attr_accessor :os
      attr_accessor :serial

      # Initializes the class using hash with keys given as below
      # @param :serial - the uuid of the device
      # @param :state - values coould be "ok","dead","offline" only
      # @param :type - values could be "Device" or "Simulator"
      # @example real_device = DeviceAPI::IOS::Device.new(:serial=>'31e2867d4c59b81f5b8470b207066404ff1db058',:state => "ok",:type => "Device")
      # @todo to implement the error handling if values of hash do not conform to above mentioned values
      def initialize(options = {})
        @os = 'iOS'
        @serial = options[:serial]
        @state = options[:state]
        @display_name = @serial
        @type = options[:type]
      end

      # Values of status can be :ok , :dead  , :offline only

      def status
        {
            'device' => :ok,
            'no device' => :dead,
            'offline' => :offline
        }[@state]
      end

      # Will return the Model Number of the device
      # @return [String] the model number of the device 

      def model
        get_prop('ModelNumber')
      end

      # installs the native ios app on the device, app should be correctly provisioned for the device on which it is being installed
      # @param app - the absolute path of .app, .zip of the application to be installed
      # @return - :success if app installed successfully else raises DeviceCommandError
      def install(app)
        fail DeviceCommandError, 'No app specified.', caller if app.empty?
        res = IDevice.install_app(serial,app)

        case res
          when true
            :success
          else
            fail DeviceCommandError, res, caller
        end
      end

      # Uninstalls the native ios app from the device
      # @param app - the Bundle id of the installed application 
      # @return :success if app uninstalled else raises DeviceCommandError

      def uninstall(bundle_id)
        res = IDevice.uninstall_app(serial,bundle_id)
        case res
          when true
            :success
          else
            fail DeviceCommandError, "Unable to uninstall bundle_id :- #{bundle_id} Error Reported: #{res}", caller
        end
      end

      # Returns the bundle id of the application name provided as param
      # @param app - the application name of the installed application 
      # @return [String] bundle_id if application name is correct else false
      def bundle_id(app)
        fail DeviceCommandError, 'No app specified.', caller if app.empty?
        bundle_id_list = IDevice.bundle_id_list(serial) 
        res = bundle_id_list[app]

        if res!=nil
            res
          else
            false
        end
      end

      # Returns the bundle id of the application name provided as param
      # @return [Hash] key value pair of application name and bundle_id
      def bundle_id_list
        
        res = IDevice.bundle_id_list(serial)
        
          if !res.empty?
            res
          else
            fail DeviceCommandError, "Could not retrieve the list of applications and bundle ids", caller
        end
      end

      # Returns the hash of properties of the device
      # @return [Hash] key value pair of property of device

      def get_props
          @props = IDevice.get_props(serial)
      end
     
      private

      def get_prop(key)
        if !@props || !@props[key]
          @props = IDevice.get_props(serial)
        end
        @props[key]
      end

      class DeviceCommandError < StandardError
      def initialize(msg)
        super(msg)
      end
    end

    end
  end
end