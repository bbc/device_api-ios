require 'device_api/ios'

describe DeviceAPI::IOS do
  describe '.devices' do
    it 'detects devices attached to device' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return( [ "12345678\n23451234\n", '', Struct.new(:exitstatus).new(0) ] )
      allow(Open3).to receive(:capture3).with('ideviceinfo -u 12345678 -k DeviceName').and_return( [ "Device-1\n", '', Struct.new(:exitstatus).new(0) ] )
      allow(Open3).to receive(:capture3).with('ideviceinfo -u 23451234 -k DeviceName').and_return( [ "Device-2\n", '', Struct.new(:exitstatus).new(0) ] )

      expect(DeviceAPI::IOS.devices).to match_array(
        [
          DeviceAPI::IOS::Device.new('12345678'),
          DeviceAPI::IOS::Device.new('23451234')
        ]
      )
    end

    it 'detects an empty list of devices' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return( [ '', '', Struct.new(:exitstatus).new(0) ] )

      expect(DeviceAPI::IOS.devices).to match([])
    end
  end
end
