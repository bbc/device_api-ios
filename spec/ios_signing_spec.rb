$LOAD_PATH.unshift( './lib/' )

require 'device_api/execution'
require 'device_api/ios/signing'
require 'yaml'

include RSpec

describe DeviceAPI::IOS::Signing do

  before(:all) do

  end

  describe ".is_ipa?" do
    it "correctly identifies an IPA" do
      expect(DeviceAPI::IOS::Signing.is_ipa?('/path/to/ipa.ipa')).to be(true)
    end

    it "correctly identifies a file that isn't an IPA" do
      expect(DeviceAPI::IOS::Signing.is_ipa?('/path/to/app.app')).to be(false)
    end
  end

  describe ".get_signing_certs" do
    it "returns an Array of Hashes containing iOS Signing Certificates" do
      expect(DeviceAPI::IOS::Signing.get_signing_certs).to be_kind_of(Array)
    end

    it "returns an Array of Hashes containing correct certificates" do
      out = <<eos
        1) 43ED4FA24518B1F72EE4FB3E6F7476E886A8E5D0 "iPhone Developer: Test Developer (ABC1234567)"
        2) 289765876A0FB55327F8F3C2A3D4FA3F1A484CFB "iPhone Developer: Test Developer (ABC1234526)"
        3) 132128763516473546816751267AFA217036217B "iPhone Developer: Test Developer (ABC1235343)"
        3 valid identities found
eos
      allow(Open3).to receive(:capture3) {
        [out, '', (Struct.new(:exitstatus)).new(0)]
      }

      expect(DeviceAPI::IOS::Signing.get_signing_certs.count).to eq(3)
    end
  end
end
