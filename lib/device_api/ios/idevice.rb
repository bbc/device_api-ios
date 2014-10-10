# Encoding: utf-8

# Provides static methods to interact with real ios device
require 'open3'
require 'ostruct'
require 'device_api/execution'

module DeviceAPI
  module IOS

    # Namespace for all methods encapsulating ios device calls
    class IDevice < DeviceAPI::Execution

      # @return [Hash] representing connected ios devices
      # @example DeviceAPI::IDevice.get_list_of_devices #=> { 'iPhone 5c' => '31e2867d4c59b81f5b8470b207066404ff1db058' }

      def self.get_list_of_devices
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

      # Retrieve device state for a single device
      # @param uuid
      def self.get_state(serial)
      
        result = execute_with_timeout_and_retry("ideviceinfo -u #{serial} -k ActivationState")

        raise IDeviceCommandError.new(result.stderr) if result.exit != 0

        lines = result.stdout.split("\n")
        /(.*)/.match(lines.last)
        Regexp.last_match[0].strip
      end

      # checks if os is mac
      def self.compatible_os?
        return ENV["_system_name"].eql?("OSX") ? true : false
      end


      # installs the native ios app on the device, app should be correctly provisioned for the device on which it is being installed
      # @param device_id - uuid of ios device on which app is to be installed
      # @param app_path - the absolute path of .app, .zip of the application to be installed
      # @return [boolean] true if success
      # @return [boolean] false if failure
      def self.install_app(device_id, app_path)
        result = execute_with_timeout_and_retry("fruitstrap -i '#{device_id}' -t 10 -b #{app_path}")

        raise IDeviceCommandError.new(result.stderr) if result.exit != 0
        
        result = result.stdout.split("\n")
        if result.last.start_with?("[100%]")
           return true 
        else
           return false # error occurred 
        end  
      end
      
      # uninstalls the native ios app from the device
      # @param device_id - uuid of ios device from which app is to be uninstalled
      # @param bundle_id - the bundle_id of application to be uninstalled
      # @return [boolean] true if success
      # @return [boolean] false if failure
      def self.uninstall_app(device_id, bundle_id)
        
        result = execute("ideviceinstaller -u '#{device_id}' -U #{bundle_id}")
        
        raise IDeviceCommandError.new(result.stderr) if result.exit != 0

        result = result.stdout.split("\n")
        if result.last.start_with?("Uninstall - Complete")
           return true
        else
          cmd = "ideviceinstaller -U '#{device_id}' -l"
          search_result = `#{cmd}`
          search_result = search_result.split("\n")
  
          search_result.each do |r|
            if r.start_with?(bundle_id)
               return false # Uninstall failed
            end
          end
         return true 
        end  
      end

      # Returns the Hash containing properties of real ios device using idevice_id -l command , Need idevice_id installed on the machine,(brew install idevice_id -l)
      # @param device_id uuid of the device
      # @return (Hash) key value pair of properties
      def self.get_props(device_id)
        
        result = execute("ideviceinfo -u '#{device_id}'")
        
        raise IDeviceCommandError.new(result.stderr) if result.exit != 0
        
        result=result.stdout
        unless result.start_with?("Usage:")
          prop_list = result.split("\n")
          props = {}
          prop_list.each do |line|
            matches = line.scan(/(.*): (.*)/)
            prop_name, prop_value = matches[0]
            props[prop_name.strip] = prop_value.strip
          end
        else
          
        end
        
        props
      end
      
      # Launches the application on the device
      # @param device_id - uuid of ios device on which app is to be launched
      # @param app_path - the absolute path of .app, .zip of the application to be launched
      # @return [boolean] true if success
      # @return [boolean] false if failure

      def self.launch_app(device_id, app_path)
        result = execute("fruitstrap -i '#{device_id}' -t 10 -m -b #{app_path}")
       
        raise IDeviceCommandError.new(result.stderr) if result.exit != 0
        
        result = result.stdout.split("\n")
        unless result.last.start_with?("[100%]")
          return false # error occurred 
        else
          return true
        end  
      end
    
      # Installs and Launches the application on the device
      # @param device_id - uuid of ios device on which app is to be installed & launched
      # @param app_path - the absolute path of .app, .zip of the application to be installed & launched
      # @return [boolean] true if success
      # @return [boolean] false if failure

      def self.install_and_launch_app(device_id, app_path)
        install_app(device_id, app_path)
        launch_app(device_id, app_path)        
      end

      # installs the native ios app on the device, app should be correctly provisioned for the device on which it is being installed
      # @param device_id - uuid of ios device on which app is to be installed
      # @param app_path - the absolute path of .app, .zip of the application to be installed
      # @return [boolean] true if success
      # @return [boolean] false if failure
      def self.bundle_id_list(device_id)
        result = execute_with_timeout_and_retry("ideviceinstaller -u #{device_id} -l")

        raise IDeviceCommandError.new(result.stderr) if result.exit != 0
        
          app_list_res = result.stdout.split("\n")
          app_list_res.shift
          app_list = {}
          app_list_res.each do |line|
            res = line.split(" - ")
            app_list[res[1].split(/\d*\..*\d$/)[0].strip] = res[0]
          end
        
        app_list
      end

      # Exception class to handle exceptions related to IDevice Class
    class IDeviceCommandError < StandardError
      def initialize(msg)
        super(msg)
      end
    end


  end
end
end

