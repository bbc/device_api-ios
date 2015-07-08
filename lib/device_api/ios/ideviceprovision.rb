# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating ideviceprovision calls
    class IDeviceProvision < Execution
      # Lists all profiles on the specified device
      # @param [String] serial serial of the device to check
      # @return [Hash] hash of profile name and UUID
      def self.list_profiles(serial)
        result = execute("ideviceprovision -u #{serial} list")

        raise IDeviceProvisionError.new(result.stderr) if result.exit != 0

        Hash[result.stdout.split("\n").map { |a| b = a.split(' - '); [b[0], b[1]] }[1..-1]]
      end

      # Checks to see if a profile is installed on the specified device
      # @param [Hash] options options used for checking profiles
      # @option options [String] :name name of the profile (optional when uuid provided)
      # @option options [String] :uuid UUID of the profile (optional when name provided)
      # @option options [String] :serial serial of the device to check
      # @return [Boolean] true if the profile is installed, false otherwise
      def self.has_profile?(options = {})
        name = options[:name]
        uuid = options[:uuid]
        serial = options[:serial]

        profiles = list_profiles(serial)

        profiles.key?(uuid) || profiles.value?(name)
      end

      # Removes the specified profile from the device
      # @param [Hash] options options used for removing a profile
      # @option options [String] :uuid UUID of the profile to be removed
      # @option options [String] :serial serial of the device to remove the profile from
      # @return [Boolean, IDeviceProvisionError] true if the profile is removed from the device, an error otherwise
      def self.remove_profile(options = {})
        uuid = options[:uuid]
        serial = options[:serial]

        return true unless has_profile?(serial: serial, uuid: uuid)

        result = execute("ideviceprovision -u #{serial} remove #{uuid}")

        raise IDeviceProvisionError.new(result.stderr) if result.exit != 0
        true
      end

      # Installs the specified profile to the device
      # @param [Hash] options options used for installing a profile
      # @option options [String] :file path to the provisioning profile
      # @option options [String] :serial serial of the device to install the profile to
      # @return [Boolean, IDeviceProvisionError] true if the profile is installed, an error otherwise
      def self.install_profile(options = {})
        serial = options[:serial]
        file = options[:file]

        info = get_profile_info(file)

        # Check to see if the profile has already been added to the device
        return true if has_profile?(serial: serial, uuid: info['UUID'])

        result = execute("ideviceprovision -u #{serial} install #{file}")

        raise IDeviceProvisionError.new(result.stderr) if result.exit != 0
        true
      end

      # Gets information about a provisioning profile
      # @param [String] file path to the provisioning profile
      # @return [Hash] hash containing provisioning profile information
      def self.get_profile_info(file)
        result = execute("ideviceprovision dump #{file}")

        raise IDeviceProvisionError.new(result.stderr) if result.exit != 0

        lines = result.stdout.split("\n")

        info = {}
        lines.each do |l|
          if /(.*):\s+(.*)/.match(l)
            info[Regexp.last_match[1]] = Regexp.last_match[2]
          end
        end
        info
      end
    end

    # Provisioning error class
    class IDeviceProvisionError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
