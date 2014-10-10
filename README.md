device_api-ios
==============

iOS Device management abstraction


Quick Setup
===========


Dependencies
=============
1. idevice_id,ideviceinstaller & ideviceinfo,osascript,ios-sim
2. appium - Same installation process as given in devicehive setup file "iOSConfigReadme.md"
3. fruitstrap
4. Applications to be installed on real devices need to be provisioned using development certificates

Initialise
---------
require 'device_api/ios'

device = DeviceAPI::IOS::Device.new(:serial=>'31e2867d4c59b81f5b8470b207066404ff1db058',:state => "ok",:type => "Device")


Device info
-----------
device.model          		#  "ME5C"


Install/uninstall apk
---------------------
device.install(@app_path)		# where @app_path is the absolute path of the application provisioned for the device
	
device.uninstall(@bundle_id)	# where @bundle_id is the bundle_id of the app to be uninstalled (bundle_id = device.bundle_id_list[app name])


