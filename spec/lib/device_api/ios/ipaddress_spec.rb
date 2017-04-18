require 'device_api/execution'
require 'device_api/ios/ipaddress'

RSpec.describe DeviceAPI::IOS::IPAddress do

  describe '.address' do
    it 'gets the correct IP Address' do

      apps = <<end
Total: 2 apps\r
uk.co.bbc.titan.IPAddress - IPAddress 1\r
uk.co.bbc.iplayer - BBC iPlayer 4.10.0.196\r
end

      output = <<end
  2015-07-06 09:27:33.670 IPAddress[801:299377] addresses: {
      "awdl0/ipv6" = "fe80::dce9:ge0f:fee7:aaad";
  "en0/ipv4" = "10.10.1.80";
  "en0/ipv6" = "fe80::147c:1496:fce9:ed2";
  "lo0/ipv4" = "127.0.0.1";
  "lo0/ipv6" = "fe80::1";
  "pdp_ip0/ipv4" = "10.7.195.3";
  }
  2015-07-06 09:27:33.672 IPAddress[801:299377] 10.10.1.80
end
      allow(Open3).to receive(:capture3).and_return(
                [apps, '', (Struct.new(:exitstatus)).new(0)],
                [output, '', (Struct.new(:exitstatus)).new(0)]
      )

      ip_address = DeviceAPI::IOS::IPAddress.address('123456')
      expect(ip_address).to eq('10.10.1.80')
    end
  end
end
