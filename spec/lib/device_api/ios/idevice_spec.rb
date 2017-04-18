require 'device_api/ios/idevice'

RSpec.describe DeviceAPI::IOS::IDevice do
  describe '.devices' do
    it 'detects devices attached to device' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return( [ "12345678\n23451234\n", '', Struct.new(:exitstatus).new(0) ] )
      allow(Open3).to receive(:capture3).with('ideviceinfo -u 12345678 -k DeviceName').and_return( [ "Device-1\n", '', Struct.new(:exitstatus).new(0) ] )
      allow(Open3).to receive(:capture3).with('ideviceinfo -u 23451234 -k DeviceName').and_return( [ "Device-2\n", '', Struct.new(:exitstatus).new(0) ] )

      expect(DeviceAPI::IOS::IDevice.devices).to match(
        {
          '12345678' => 'Device-1',
          '23451234' => 'Device-2'
        }
      )
    end

    it 'detects an empty list of devices' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return( [ '', '', Struct.new(:exitstatus).new(0) ] )

      expect(DeviceAPI::IOS::IDevice.devices).to match({})
    end
  end

  describe '#trusted?' do
    it 'reports a connected device as trusted' do
      allow(Open3).to receive(:capture3).with("ideviceinfo -u '00000001'").and_return( [ "ActivationState: Activated\nActivationStateAcknowledged: true\nBasebandActivationTicketVersion: V2\nBasebandCertId: 2\n", '', Struct.new(:exitstatus).new(0) ] )
      expect(DeviceAPI::IOS::IDevice.trusted?('00000001')).to be_truthy
    end

    it 'reports a connected device as not trusted' do
      allow(Open3).to receive(:capture3).with("ideviceinfo -u '00000001'").and_return( [ '', "ERROR: Could not connect to lockdownd, error code -19\n", Struct.new(:exitstatus).new(255) ] )
      expect(DeviceAPI::IOS::IDevice.trusted?('00000001')).to be_falsey
    end

    it 'reports a not connected device as not trusted' do
      # So apparently calling ideviceinfo with an unknown id results in a success
      allow(Open3).to receive(:capture3).with("ideviceinfo -u '00000001'").and_return( [ "Usage: ideviceinfo [OPTIONS]\nShow information about a connected device.\n\n  -d, --debug   enable communication debugging\n", '', Struct.new(:exitstatus).new(0) ] )
      expect(DeviceAPI::IOS::IDevice.trusted?('00000001')).to be_falsey
    end

    it 'reports a success with no output as not trusted' do
      # This is unlikely but can occur
      # Possibly due to a race condition
      allow(Open3).to receive(:capture3).with("ideviceinfo -u '00000001'").and_return( [ '', '', Struct.new(:exitstatus).new(0) ] )
      expect(DeviceAPI::IOS::IDevice.trusted?('00000001')).to be_falsey
    end
  end
end
