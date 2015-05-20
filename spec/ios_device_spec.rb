$LOAD_PATH.unshift( './lib/' )

require 'device_api/execution'
require 'device_api/ios/idevice'
require 'device_api/ios/device'
require 'yaml'

include RSpec

ProcessStatusStub = Struct.new(:exitstatus)
$STATUS_ZERO = ProcessStatusStub.new(0)

describe DeviceAPI::IOS do

  before(:all) do
   
    config_file = '../../config.yml'
    CONFIG = YAML.load_file(File.expand_path(config_file, __FILE__))
    @bundle_id = CONFIG["bundle_id"]
    @app_path = File.expand_path(CONFIG["app_path"])
    @arr_devices = DeviceAPI::IOS::IDevice.get_list_of_devices
    keys = @arr_devices[0].keys
    @test_device_uuid = keys[0]
    @app_name = CONFIG["app_name"]

  end

  describe ".model" do

    before(:each) do
      @ios_device = DeviceAPI::IOS::Device.new(:serial=>@test_device_uuid,:state => "ok",:type => "Device")
    end

    it "returns model of device" do
        props = DeviceAPI::IOS::IDevice.get_props(@test_device_uuid)
        expect(props['ModelNumber']).to eq(@ios_device.model)
    end

             
  end
 
  

  describe ".install" do

    before(:each) do
      
      result = DeviceAPI::Execution.execute("ideviceinstaller -u #{@test_device_uuid} -l")
      if(result.stdout.include? @bundle_id and result.stderr=="")
          DeviceAPI::Execution.execute("ideviceinstaller -u '#{@test_device_uuid}' -U #{@bundle_id}")
       end 

       @ios_device = DeviceAPI::IOS::Device.new(:serial=>@test_device_uuid,:state => "ok",:type => "Device")
      
    end

    it "returns successfully installed message once ios app is installed on a device" do
        expect(@ios_device.install(@app_path)).to eq :success
    end
    

  end

  describe ".uninstall" do

    before(:each) do
      @ios_device = DeviceAPI::IOS::Device.new(:serial=>@test_device_uuid,:state => "ok",:type => "Device")
      app_bundle_list = @ios_device.bundle_id_list
      app_names = app_bundle_list.keys
      result = DeviceAPI::Execution.execute("ideviceinstaller -u #{@test_device_uuid} -l")

      if(!app_names.include? @app_name)
          DeviceAPI::Execution.execute("ideviceinstaller -u '#{@test_device_uuid}' -i #{@app_path}")
          @local_bundle_id = (@ios_device.bundle_id_list)[@app_name]
       else
          @local_bundle_id = app_bundle_list[@app_name]
       end 
    end
    
   it "Uninstalls the app from ios device" do
      res = @ios_device.uninstall(@local_bundle_id)
      expect( res ).to eq :success
      
    end
   
    
  end
  
  describe ".get_props" do
    before(:each) do
      @ios_device = DeviceAPI::IOS::Device.new(:serial=>@test_device_uuid,:state => "ok",:type => "Device")
    end
    
    it "Returns a hash of name value pair properties" do
      props = @ios_device.get_props
      expect( props ).to be_a Hash
      expect( props['ActivationState']).to eq('Activated')
    end
    
  end

    
end

