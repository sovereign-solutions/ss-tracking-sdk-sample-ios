# TCTracking

[![CI Status](https://img.shields.io/travis/PhuTruong/TCTracking.svg?style=flat)](https://travis-ci.org/PhuTruong/TCTracking)
[![Version](https://img.shields.io/cocoapods/v/TCTracking.svg?style=flat)](https://cocoapods.org/pods/TCTracking)
[![License](https://img.shields.io/cocoapods/l/TCTracking.svg?style=flat)](https://cocoapods.org/pods/TCTracking)
[![Platform](https://img.shields.io/cocoapods/p/TCTracking.svg?style=flat)](https://cocoapods.org/pods/TCTracking)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Quick start

run the example project
- In your info.plist add these keys and descriptions: NSLocationWhenInUseUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription, NSLocationAlwaysUsageDescription, NSMotionUsageDescription
- driverName: user's name
- accessToken: input access token 
- apiVersion: api versin form APi
- trackingURL: URL domain for api version < 2.0.0
- backendURL: URL tracking version >= 2.0.0
- use the LoginUrl with your username and password to get the `token`, `refreshToken`
        curl --location 'https://accounts.skedulomatic.com/oauth/token' \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode 'grant_type=password' \
        --data-urlencode 'username=<username>' \
        --data-urlencode 'password=<password>
        
        let user = "thanh13"
        let token = "bearer f0ue9Ce6swJXku2IH8h_....."
        let refreshToken = "rvFTI9O9oXggF6FeqvIxbWaeno57aax....."
        SVTrackingManager.shareInstance.configData(driverName: "thanh13", accessToken: token, trackingURL: "https://testing.skedulomatic.com/api/app-base/vdms-tracking/push", backendURL: "https://testing.skedulomatic.com", apiVersion: "2.7.2", jobStatus: 2)
        SVTrackingManager.shareInstance.setTrackingFrequency(miliseconds: 10000)
        SVTrackingManager.shareInstance.setUseMotionSensor(enable: true)
        SVTrackingManager.shareInstance.setAuthenInfo(url:"https://accounts.skedulomatic.com/oauth/token", refreshToken: refreshToken, expiresIn:String(1653625868533))
        SVTrackingManager.shareInstance.enableService()

## Requirements

IOS 11.0 or later

## Installation

TCTracking is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TCTracking', 'https://github.com/phutttc/TCTracking'
```

## Author

PhuTruong, phu.truong@techcraft.vn

## License

TCTracking is available under the MIT license. See the LICENSE file for more info.
