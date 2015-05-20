# device_api-ios


device_api-ios is the iOS implementation of device_api - an initiative to allow full automation of device activities

## Dependencies

device_api-ios shells out to a number of iOS command line tools. You will need to make sure that the libimobiledevice library is installed and the following commands are available on your path:
* ideviceinfo

## Using the gem

Add the device_api-ios gem to your gemfile - this will automatically bring in the device_api base gem on which the iOS gem is built.

    gem 'device_api-ios'

You'll need to require the library in your code:

    require 'device_api/ios'

Try connecting an iOS device with USB and run:

    device = DeviceAPI::IOS.devices

You might need to accept the 'Trust this computer' dialog on your device.

### Detecting devices

There are two methods for detecting devices:
    DeviceAPI::IOS.devices
This returns an array of objects representing the connected devices. You will get an empty array if there are no connected devices.
    DeviceAPI::IOS.device(serial_id)
This looks for a device with a matching serial_id and returns a single device object.

### Device object

When device-api-detects a device, it returns a device object that lets you interact with and query the device with various iOS tools.

For example:

        device = DeviceAPI::IOS.device(serial_id)
        device.serial # '50d9299992726df277bg6befdf88e1704f4f8f8b'
        device.model # 'iPad mini 3'
