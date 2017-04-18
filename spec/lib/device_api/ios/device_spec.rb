require 'device_api/ios/device'

RSpec.describe DeviceAPI::IOS::Device do
  describe '.create' do
    it 'creates an instance of DeviceAPI::IOS::Device' do
      expect(DeviceAPI::IOS::Device.create({qualifier: '12345'})).to be_a DeviceAPI::IOS::Device
    end

    it 'sets the serial to be the qualifier' do
      expect(DeviceAPI::IOS::Device.create({qualifier: '12345'}).serial).to eq '12345'
    end

    it 'uses serial to override the qualifer if it is set' do
      expect(DeviceAPI::IOS::Device.create({qualifier: '12345', serial: '98765'}).serial).to eq '98765'
    end

    it 'sets the qualifier' do
      expect(DeviceAPI::IOS::Device.create({qualifier: '12345'}).qualifier).to eq '12345'
    end

    it 'does not override the qualifier with the serial' do
      expect(DeviceAPI::IOS::Device.create({qualifier: '12345', serial: '98765'}).qualifier).to eq '12345'
    end
  end
end
