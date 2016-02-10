require 'device_api/execution'
require 'device_api/ios/plistutil'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class Signing < Execution

      # Check to see if the path is an IPA
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

      def self.sign_app(options = {})
        cert          = options[:cert]
        entitlements  = options[:entitlements]
        app           = options[:app]
        original_app  = nil

        if is_ipa?(app)
          original_app = app
          app = unpack_ipa(app)
        end

        # Check to see if the entitlements passed in is a file or the XML
        unless File.exists?(entitlements)
          file = Tempfile.new('entitlements')
          file.write(entitlements)
          file.close
          entitlements = file.path
        end

        result = execute("codesign --force --sign '#{cert}' --entitlements #{entitlements} '#{app}'")

        raise SigningCommandError.new(result.stderr) if result.exit != 0

        zip_app(app, original_app) if original_app
      end

      def self.zip_app(payload_path, ipa_path)
        result = execute("cd #{File.dirname(payload_path)}; zip -r #{ipa_path} ../Payload ")
        raise SigningCommandError.new(result.stderr) if result.exit != 0

        true
      end

      def self.get_signing_certs
        result = execute('security find-identity -p codesigning -v')

        raise SigningCommandError.new(result.stderr) if result.exit != 0

        certs = []
        result.stdout.split("\n").each do |line|
          if /\)\s*(\S*)\s*"(.*)"/.match(line)
            certs << { id: Regexp.last_match[1], name: Regexp.last_match[2] }
          end
        end
        certs
      end

      def self.get_entitlements(app_path, raw = false)
        app_path = unpack_ipa(app_path) if is_ipa?(app_path)
        result = execute("codesign -d --entitlements - #{app_path}")

        if result.exit != 0
          raise SigningCommandError.new(result.stderr)
        end

        # Clean up the result as it occasionally contains invalid UTF-8 characters
        xml = result.stdout.to_s.encode('UTF-8', 'UTF-8', invalid: :replace)
        xml = xml[xml.index('<')..xml.length]

        return xml if raw
        entitlements = Plistutil.parse_xml(xml)
        return entitlements
      end

      def self.enable_get_tasks(app_path)
        entitlements = get_entitlements(app_path, raw: true)

        return entitlements if entitlements.scan(/<key>get-task-allow<\/key>\\n.*<true\/>/).count > 0

        entitlements.gsub('<false/>', '<true/>') if entitlements.scan(/<key>get-task-allow<\/key>\\n.*<false\/>/)
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