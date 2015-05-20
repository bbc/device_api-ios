$LOAD_PATH.unshift( './lib/' )

require 'device_api/execution'
require 'device_api/ios/idevice'
require 'yaml'

include RSpec

ProcessStatusStub = Struct.new(:exitstatus)
$STATUS_ZERO = ProcessStatusStub.new(0)

describe DeviceAPI::IOS::IDevice do

  before(:all) do
   
    config_file = '../../config.yml'
    CONFIG = YAML.load_file(File.expand_path(config_file, __FILE__))
    @bundle_id = CONFIG["bundle_id"]
    @app_path = File.expand_path(CONFIG["app_path"])
    @arr_devices = DeviceAPI::IOS::IDevice.get_list_of_devices
    keys = @arr_devices[0].keys
    @test_device_uuid = keys[0]

  end

  describe ".get_list_of_devices" do

    before(:each) do
      @arr_devices = DeviceAPI::IOS::IDevice.get_list_of_devices
    end

    it "returns an Array of connected ios devices" do
        expect(@arr_devices.class).to eq(Array)
    end

    it "returns an Array of Hash of connected ios devices - When atleast one devices is connected" do
        expect(@arr_devices[0].class).to eq(Hash)
    end
          
  end
  
  describe ".get_state" do
 
    it "returns state of a device based on the device - When atleast one device is connected" do
       expect( DeviceAPI::IOS::IDevice.get_state(@test_device_uuid)).to eq("Activated")
    end


  end

  describe ".install_app" do

    before(:each) do
      
      result = DeviceAPI::Execution.execute("ideviceinstaller -u #{@test_device_uuid} -l")
      if(result.stdout.include? @bundle_id and result.stderr=="")
          DeviceAPI::Execution.execute("ideviceinstaller -u '#{@test_device_uuid}' -U #{@bundle_id}")
       end 
      
    end

    it "returns successfully installed message once ios app is installed on a device" do
       expect( DeviceAPI::IOS::IDevice.install_app(@test_device_uuid,@app_path)).to eq true
    end
    

  end

  describe ".launch_app" do

    before(:each) do
      
      result = DeviceAPI::Execution.execute("ideviceinstaller -u #{@test_device_uuid} -l")
      if(result.stdout.include? @bundle_id and result.stderr=="")
          DeviceAPI::Execution.execute("ideviceinstaller -u '#{@test_device_uuid}' -U #{@bundle_id}")
       end 
      
    end
    
   it "Launches the app on the ios device" do
      props = DeviceAPI::IOS::IDevice.launch_app(@test_device_uuid,@app_path)
      expect( props ).to eq true
      
    end
   
    
  end
  
  describe ".get_props" do
    
    it "Returns a hash of name value pair properties" do
      props = DeviceAPI::IOS::IDevice.get_props(@test_device_uuid)
      expect( props ).to be_a Hash
      expect( props['ActivationState']).to eq('Activated')
    end
    
  end

  describe ".bundle_id_list" do
    
    it "Returns a hash of name value pair of application name and bundle_id" do
      list = DeviceAPI::IOS::IDevice.bundle_id_list(@test_device_uuid)
      expect(list).to be_a Hash
    end
    
  end
  
end

