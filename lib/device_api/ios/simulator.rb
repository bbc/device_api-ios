# Encoding: utf-8
# Provides static methods to interact with real ios device
require 'open3'
require 'ostruct'
require 'device_api/execution'
require 'device_api'
require 'yaml'

module DeviceAPI
  module IOS
    # Namespace for all methods encapsulating ios simulator calls
    class Simulator < DeviceAPI::Execution
      
      config_file = '../../../../config.yml'
      CONFIG = YAML.load_file(File.expand_path(config_file, __FILE__))

      IOS_SIM_SCRIPT = File.expand_path(CONFIG['ios_sim_scpt'])

      # checks if os is mac
      def self.compatible_os?
        return ENV["_system_name"].eql?("OSX") ? true : false
      end
    
      # @return [String] gives the uuid of the simulator currently open
      def self.get_uuid
        if @uuid == nil
          cmd = "system_profiler SPHardwareDataType | awk '/Hardware UUID:/ {print tolower(gsub(/-/,\"\") $NF)}'"
          output = `#{cmd}`
          output = output.split("\n")
          unless output[0]
            @uuid = ""
          end
          @uuid = output[0]
        end
        @uuid
      end
      
      # @return [Hash] representing sdk's installed on the machine
      # @example DeviceAPI::IDevice.get_list_of_devices #=> { '6.0' => '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.0.sdk' }
      def self.get_list_of_sdks
        sdks = {}
  
        cmd = 'ios-sim showsdks'
        result = `#{cmd} 2>&1`
  
        sdk_list = result.split("\n")
        
        if sdk_list.length < 1
          return false # no sdks installed
        end
        
        sdk_list = sdk_list[1..-1]
  
        sdk_list.each_slice(2) do |sdk|
          # Regex is crucial in the hash calculation
          sdks[sdk[0].gsub(/'Simulator - iOS \d\.\d' /,"").gsub(/[\(\)]/,"")] = sdk[1].strip        
        end
        
        sdks
      end
  
      # Returns the Hash containing properties of ios simulator
      # @return (Hash) key value pair of the property (Gives on one key value pair)
      def self.get_props
        if is_running?
        cmd = "osascript " + IOS_SIM_SCRIPT + " getprops"
        output = `#{cmd} 2>&1`
        output.split(" - ")
      else
        false
      end
      end
      
      # Tells whether any simulator is open or not
      # @return [boolean] true if simulator open
      # @return [boolean] false if not simulator is open
      def self.is_running?
        cmd = "killall -s 'iPhone Simulator'"
        result = `#{cmd} 2>&1`
        result = result.split("\n")
        if result[0].start_with?("kill")
          true
        else
          false
        end
        !!result[0].start_with?("kill")
      end
  
      # Tells whether any simulator is open or not
      # @return [boolean] true if simulator open
      # @return (Hash) key value pair of uuid and "simulator"
      # @example "5B3695A1-A423-5BA4-A28F-D627DC19388B" => "simulator"
      def self.get_simulator
        if compatible_os?
          return Hash[get_uuid, "simulator"] if is_running? 
        end
        {}
      end
      
      # Starts a simulator basis given parameters
      # @param device_type valid values "iphone", "ipad"
      # @param sdk valid values "6.0" "7.0" "7.1" etc
      # @param is_retina true or false
      # @param is_tall true or false
      # @return [boolean] true if simulator opens
      # @return [boolean] false if not simulator is opened
      
      def self.start(device_type, sdk, is_retina, is_tall)
        cmd = "ios-sim start --family #{device_type} --sdk #{sdk}" + 
        (is_retina ? " --retina" : "") + (is_tall ? " --tall" : "") + " --verbose --exit"
  
        result = `#{cmd} 2>&1`
        result = result.split("\n")
        
        if result.last.start_with?("Simulator started")
          return true 
        else
          return false # error occurred 
        end
      end
      
      # Installs and Launches the application on the simulator
      # @param app_path - the absolute path of .app, .zip of the application to be installed & launched
      # @param device_type valid values "iphone", "ipad"
      # @param sdk valid values "6.0" "7.0" "7.1" etc
      # @param is_retina true or false
      # @param is_tall true or false
      # @return [boolean] true if success
      # @return [boolean] false if failure
      def self.install_and_launch_app(app_path, device_type, sdk, is_retina, is_tall)
        cmd = "ios-sim launch #{app_path} --family #{device_type} --sdk #{sdk}" + 
        (is_retina ? " --retina" : "") + (is_tall ? " --tall" : "") +   " --verbose --exit"
  
        result = `#{cmd} 2>&1`
        result = result.split("\n")
        if result.last.start_with?("Session started")        
          return true 
        else
          return false # error occurred 
        end
      end
      
      # Brings the screen to the home screen of the simulator
      # @return [boolean] true if success
      # @return [boolean] false if failure
      def self.go_home
        cmd = "osascript " + IOS_SIM_SCRIPT + " home"
        result = `#{cmd} 2>&1`
       
        if result.include? "error"        
          return false # error occurred 
        else
          return true
        end
      end
      # Closes the simulator
      # @return [boolean] true if closed
      # @return [boolean] false if not closed
      def self.close

        cmd = "osascript " + IOS_SIM_SCRIPT + " close"
        
        result = `#{cmd} 2>&1`
       
        if result.include? "error"        
          return false # error occurred 
        else
          return true
        end
      end
    end
  end
end
