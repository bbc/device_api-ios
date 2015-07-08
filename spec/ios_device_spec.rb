require 'device_api/execution'
require 'device_api/ios/idevice'
require 'device_api/ios/device'
require 'device_api/ios'

include RSpec

describe DeviceAPI::IOS do

  describe ".model" do

    it 'returns the model of the attached device' do
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
      device = DeviceAPI::IOS.device('123456')
      expect(device.trusted?).to eq(false)
    end

    it 'returns device state' do
      device = DeviceAPI::IOS.device('123456')
      expect(device.status).to eq(:ok)
    end
  end
end

