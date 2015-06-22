require 'device_api/execution'
require 'pry'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class Signing < Execution

      def self.is_ipa?(path)
        return true if (File.extname path).downcase == '.ipa'
        false
      end

      def self.unpack_ipa(path)
        folder = File.dirname(path)
        target = (File.basename path, (File.extname path))

        # Check to see if the target has already been unzipped
        return Dir["#{folder}/#{target}/Payload/*.app"].first if File.exists? ("#{folder}/#{target}/Payload/")

        result = execute("unzip '#{path}' -d '#{folder}/#{target}'")
        raise SigningCommandError.new(result.stderr) if result.exit != 0

        Dir["#{folder}/#{target}/Payload/*.app"].first
      end

      def self.is_app_signed?(app_path)
        app_path = unpack_ipa(app_path) if is_ipa?(app_path)
        result = execute("codesign -d -vvvv '#{app_path}'")

        if result.exit != 0
          return false if /is not signed/.match(result.stderr)
          raise SigningCommandError.new(result.stderr)
        end

        true
      end
    end

    # Signing error class
    class SigningCommandError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end