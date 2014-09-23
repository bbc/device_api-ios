# device_api-iOS

device_api-ios is the iOS implementation of device_api -- an initiative to allow full automation of device activities.

## Dependencies

<list of command line programs and other libraries needed to be installed>

## Using the gem

Add the device_api-ios gem to your gemfile -- this will automatically bring in the device_api base gem on which the iOS gem is built.

    gem 'device_api-ios'
  
You'll need to require the library in your code:

    require 'device_api/ios'

Try connecting an iOS device with usb, and run:

    device = DeviceAPI::iOS.devices

<any other usage instructions here>

### Detecting devices

There are two methods for detecting devices:
    DeviceAPI::iOS.devices 
This returns an array of objects representing the connected devices. You get an empty array if there are no connected devices.
    DeviceAPI::iOS.device(serial_id)
    
This looks for a device with a matching serial_id and returns a single device object.

<any other device detection here>

### Device object

When device-api detects a device, it returns a device object that lets you interact with and query the device with various iOS tools.

For example:
    device = DeviceAPI::iOS.device(serial_id)
    device.serial # "01498A0004005015"
    device.model # "iPAD"

#### Device orientation

device.orientation # :landscape / :portrait

## Testing

device_api-ios is defended with unit and integration level rspec tests. You can run the tests with:
    bundle exec rspec
