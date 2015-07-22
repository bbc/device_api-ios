require 'device_api/execution'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class IDeviceInstaller < Execution
      # Installs a given IPA to the specified device
      # @param [Hash] options options for installing the app
      # @option options [String] :ipa path to the IPA to install
      # @option options [String] :serial serial of the target device
      # @return [Boolean] true if successful, otherwise false
      def self.install_ipa(options = {})
        options[:action] = :install
        change_package(options)
      end

      # Uninstalls a specified package from a device
      # @param [Hash] options options for uninstalling the app
      # @option options [String] :package bundle ID of the package to be uninstalled
      # @option options [String] :serial serial of the target device
      # @return [Boolean] true if successful, otherwise false
      def self.uninstall_package(options = {})
        options[:action] = :uninstall
        change_package(options)
      end

      def self.change_package(options = {})
        package = options[:package]
        ipa = options[:ipa]
        serial = options[:serial]
        action = options[:action]

        command = nil
        if action == :install
          command = "ideviceinstaller -u '#{serial}' -i '#{ipa}'"
        elsif action == :uninstall
          command = "ideviceinstaller -u '#{serial}' -U '#{package}'"
        end

        raise IDeviceInstallerError.new('No action specified') if command.nil?

        result = execute(command)

        raise IDeviceInstallerError.new(result.stderr) if result.exit != 0

        lines = result.stdout.split("\n").map { |line| line.gsub('-', '').strip }

        return true if lines.last.match('Complete')
        false
      end

      # Lists packages installed on the specified device
      # @param [String] serial serial of the target device
      # @return [Hash] hash containing installed packages
      def self.list_installed_packages(serial)
        result = execute("ideviceinstaller -u '#{serial}' -l")

        raise IDeviceInstallerError.new(result.stderr) if result.exit != 0

        lines = result.stdout.split("\n")
        lines.shift
        packages = {}
        lines.each do |line|
          if /(.*)\s+-\s+(.*)\s+(\d.*)/.match(line)
            packages[Regexp.last_match[2]] = { package_name: Regexp.last_match[1], version: Regexp.last_match[3] }
          end
        end
        packages
      end

      # Check to see if a package is installed
      # @param [Hash] options options for checking for installed package
      # @option options [String] :package package ID to check for
      # @option options [String] :serial serial of the target device
      # @return [Boolean] true if the package is installed, false otherwise
      def self.package_installed?(options = {})
        package = options[:package]
        serial  = options[:serial]

        installed_packages = list_installed_packages(serial)

        matches = installed_packages.select { |_, values| values[:package_name] == package }
        return !matches.empty?
      end
    end

    # Error class for IDeviceInstaller class
    class IDeviceInstallerError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end