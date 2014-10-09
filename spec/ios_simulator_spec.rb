$LOAD_PATH.unshift( './lib/' )

require 'device_api/execution'
require 'device_api/ios/simulator'
require 'yaml'

describe DeviceAPI::IOS::Simulator do
  describe ".get_uuid" do

    before(:each) do
      #start a simulator
      
      if !DeviceAPI::IOS::Simulator.is_running?
          DeviceAPI::IOS::Simulator.start("iphone","7.1",false,false)
      end
    end

    it "Returns uuid of the simulator" do
      result = DeviceAPI::Execution.execute_with_timeout_and_retry("system_profiler SPHardwareDataType | awk '/Hardware UUID:/ {print tolower(gsub(/-/,\"\") $NF)}'")
      uuid = result.stdout.split("\n")[0]
      expect(DeviceAPI::IOS::Simulator.get_uuid).to eq(uuid)
    end


    after(:each) do
      if  DeviceAPI::IOS::Simulator.is_running?
          DeviceAPI::IOS::Simulator.close
      end
    end

  end

  describe ".get_list_of_sdks" do

    it "Returns hash of sdks installed on the machine" do
      
      sdks = {}
      sdk_list = DeviceAPI::Execution.execute("ios-sim showsdks").stderr
          if sdk_list.length < 1
            sdk_list = false # no sdks installed
          else
            sdk_list = sdk_list.split("\n")
            sdk_list = sdk_list[1..-1]
    
            sdk_list.each_slice(2) do |sdk|
              sdks[sdk[0].gsub(/'Simulator - iOS \d\.\d' /,"").gsub(/[\(\)]/,"")] = sdk[1].strip        
            end
        end
      
      result = DeviceAPI::IOS::Simulator.get_list_of_sdks
      expect(result.to_s).to eq(sdks.to_s)
    end

  end

  describe ".get_props" do

    before(:each) do
      if !DeviceAPI::IOS::Simulator.is_running?
          DeviceAPI::IOS::Simulator.start("iphone","7.1",false,false)
      end
    end

    it "Returns the property of a simulator" do
      config_file = '../../config.yml'
      CONFIG = YAML.load_file(File.expand_path(config_file, __FILE__))
      IOS_SIM_SCRIPT = File.expand_path(CONFIG['ios_sim_scpt'])
      prop = DeviceAPI::Execution.execute("osascript " + IOS_SIM_SCRIPT + " getprops").stdout.split(" - ")

      result = DeviceAPI::IOS::Simulator.get_props
      expect(result[0]).to eq(prop[0])
    end

     after(:each) do
      if  DeviceAPI::IOS::Simulator.is_running?
          DeviceAPI::IOS::Simulator.close
      end
    end

  end

 end
