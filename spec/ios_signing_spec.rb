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
      out = <<-eos
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

  describe "entitlements" do
    plist = <<-eos
    <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>application-identifier</key>
          <string>uk.co.bbc.test</string>
          <key>com.apple.developer.team-identifier</key>
          <string>ABC1DE2345</string>
          <key>get-task-allow</key>
          <false/>
          <key>keychain-access-groups</key>
          <array>
            <string>uk.co.bbc.iplayer.test</string>
          </array>
        </dict>
        </plist>
    eos

    it 'returns a list of entitlements for an app' do
      allow(Open3).to receive(:capture3) {
        [plist, '', (Struct.new(:exitstatus)).new(0)]
      }

      expected_result = {
          'application-identifier' => 'uk.co.bbc.test',
          'com.apple.developer.team-identifier' => 'ABC1DE2345',
          'get-task-allow' => 'false'
      }
      expect(DeviceAPI::IOS::Signing.get_entitlements('')).to eq(expected_result)
    end

    it 'should replace the entitlements for an app' do
      expected = <<-eos
<?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>application-identifier</key>
          <string>uk.co.bbc.test</string>
          <key>com.apple.developer.team-identifier</key>
          <string>ABC1DE2345</string>
          <key>get-task-allow</key>
          <true/>
          <key>keychain-access-groups</key>
          <array>
            <string>uk.co.bbc.iplayer.test</string>
          </array>
        </dict>
        </plist>
      eos
      allow(Open3).to receive(:capture3) {
        [plist, '', (Struct.new(:exitstatus)).new(0)]
      }
      expect(DeviceAPI::IOS::Signing.enable_get_tasks('test.ipa')).to eq(expected)
    end
  end
end
