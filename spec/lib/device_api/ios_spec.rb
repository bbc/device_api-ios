require 'device_api/ios'

RSpec.describe DeviceAPI::IOS do
  describe ".model" do
    it 'returns the model of the attached device' do
      skip 'This is not being mocked properly. Needs reviewing.'
      device = DeviceAPI::IOS.device('123456')
      expect(device.model).to eq('Unknown iOS device')
    end

    it 'returns the correct result when a device is trusted' do
      device = DeviceAPI::IOS.device('123456')
      output = <<end
ActivationState: Activated
ActivationStateAcknowledged: true
end
      allow(Open3).to receive(:capture3) {
        [output, '', (Struct.new(:exitstatus)).new(0)]
      }
      expect(device.trusted?).to eq(true)
    end

    it 'returns the correct result when a device is not trusted' do
      skip 'This is not being mocked properly. Needs reviewing.'
      device = DeviceAPI::IOS.device('123456')
      expect(device.trusted?).to eq(false)
    end

    it 'returns device state' do
      skip 'This is not being mocked properly. Needs reviewing.'
      device = DeviceAPI::IOS.device('123456')
      expect(device.status).to eq(:ok)
    end

    it 'returns the device name' do
      output = <<-end
        Test Device
      end
      allow(Open3).to receive(:capture3) {
        [output, '', (Struct.new(:exitstatus)).new(0)]
      }
      device = DeviceAPI::IOS.device('123456')
      expect(device.name).to eq('Test Device')
    end
  end

  describe '.devices' do
    it 'detects devices attached to device' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return( [ "12345678\n23451234\n", '', Struct.new(:exitstatus).new(0) ] )
      allow(Open3).to receive(:capture3).with('ideviceinfo -u 12345678 -k DeviceName').and_return( [ "Device-1\n", '', Struct.new(:exitstatus).new(0) ] )
      allow(Open3).to receive(:capture3).with('ideviceinfo -u 23451234 -k DeviceName').and_return( [ "Device-2\n", '', Struct.new(:exitstatus).new(0) ] )

      devices = DeviceAPI::IOS.devices
      expect(devices.length).to eq 2
      expect(devices.map{|d| d.serial}).to match_array(['12345678', '23451234'])
    end

    it 'detects an empty list of devices' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return( [ '', '', Struct.new(:exitstatus).new(0) ] )

      expect(DeviceAPI::IOS.devices).to match([])
    end
  end
end
