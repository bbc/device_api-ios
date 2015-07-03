# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class IPAddress < Execution
      def self.install_ipaddress(serial)
        package_path = "#{_dir_}/../../IPAddress.ipa"
        package = DeviceAPI::IOS::Plistutil.get_bundle_id_from_app(package_path)
        unless DeviceAPI::IOS::IDeviceInstaller.package_installed?( serial: serial, package: package )
          DeviceAPI::IOS::IDeviceInstaller.install_ipa( serial: serial, package: package_path )
        end
      end



    end
  end
end