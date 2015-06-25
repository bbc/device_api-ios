require 'device_api/ios/plistutil'

describe DeviceAPI::IOS::Plistutil do
  describe ".get_app_bundle_id" do
    it "returns the correct app bundle" do

      xml = <<end
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>CFBundleIdentifier</key>
    <string>com.example.apple-samplecode.UICatalog</string>
  </dict>
</plist>
end

      allow(Open3).to receive(:capture3) {
        [xml, '', (Struct.new(:exitstatus)).new(0)]
      }
      bundle = DeviceAPI::IOS::Plistutil.get_bundle_id_from_plist('Info.plist')
      expect(bundle['CFBundleIdentifier']).to eq('com.example.apple-samplecode.UICatalog')
    end
  end
end