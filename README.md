# TCTracking

[![CI Status](https://img.shields.io/travis/PhuTruong/TCTracking.svg?style=flat)](https://travis-ci.org/PhuTruong/TCTracking)
[![Version](https://img.shields.io/cocoapods/v/TCTracking.svg?style=flat)](https://cocoapods.org/pods/TCTracking)
[![License](https://img.shields.io/cocoapods/l/TCTracking.svg?style=flat)](https://cocoapods.org/pods/TCTracking)
[![Platform](https://img.shields.io/cocoapods/p/TCTracking.svg?style=flat)](https://cocoapods.org/pods/TCTracking)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Quick start

run the example project
- driverName: user's name
- accessToken: input access token 
- apiVersion: api versin form APi
- trackingURL: URL domain for api version < 2.0.0
- backendURL: URL tracking version >= 2.0.0

        SVTrackingManager.shareInstance.configData(driverName: "thanh13", accessToken: "f0ue9Ce6swJXku2IH8h_Sxne-0GHyGOrAvuDIVL3JctF-7nJLYw2qmbBhdGmwnD3wD32VO5-4pi8KwXgIVsKA71mJWOEqd1d4P4IhqbsNJaFR_ZKEOPGhF-puEEnFD7TRguTFPO84tp5Pd3b59DSRDeUa-al5zls1nXUZWqEn7Nlpju2Enmwnto7gDxApZloNw8vxTyX38IpUmpUy3FKVby-0ykEHQy9ckROOn_P-4UdhyiPgey7ttCsHRHqHV3-qpykPR0sYxhGByZMv7ZuWeOiNSTkpWcy4bfvLaSeIfa_9Va6AIh4uedqxdTQbG2Xzo4agQhg1ykuEWVKhWzHwOi3znZb-OUwM8EFSvnIq8sDhBITj88Pznu0I7akownlUqELKIKaWDzuAcLFvlnZa276Af7lXI7r_76eAMQAzb23Ei07wc1LjaRmIJpixGdwXzDbxKyCpHGwW6dMSwcyUfndatY", trackingURL: "https://testing.skedulomatic.com/api/app-base/vdms-tracking/push", backendURL: "https://testing.skedulomatic.com", apiVersion: "2.7.2", jobStatus: 2)
        SVTrackingManager.shareInstance.setTrackingFrequency(miliseconds: 10000)
        SVTrackingManager.shareInstance.setUseMotionSensor(enable: true)
        SVTrackingManager.shareInstance.setAuthenInfo(url:"https://accounts.skedulomatic.com/oauth/token", refreshToken: "rvFTI9O9oXggF6FeqvIxbWaeno57aaxBcKuuPcSKcqWaoIk8Ph-Vang7UiNaO_GnwQbnjwtDnYo-cycJxysoYeOZjBKIcutDWCmtwMo1FaVUX8qGQqA74B1ZAp6aZQifsf6b7GnM2H7y2H3xI--Xpvfu03AXxcj8FrH_F0E6j35--KqsGS-zBKZDhgDdVdbFqwboXeK5-n_2LJngc9w-ZA43T5hqMdojjzjFarRs120kSNQE63BazUddRqZJ9XfuY36bX4Rf9Vs62L1OZZNlkum5-kHpFOH6_tOuwADELUo7UTqlJwuO1vMNqFppcHeuGZCAJSdEGWDbYKNH8CJ-h4AANM_0D2XnM8s58IQHz9QsLj2eRPHYJ6Iht-A29FW7-tmpN834p072AjjK5XQINW3eexuWKc2-IaAkzJfrDgPrra5eM84hscJrYGoy0X0YdnkAhcnZtIHaZneISvcu2UKgeeg", expiresIn:String(1653625868533))
        SVTrackingManager.shareInstance.enableService()

## Requirements

IOS 11.0 or later

## Installation

TCTracking is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TCTracking'
```

## Author

PhuTruong, truongthienphu@vietbando.vn

## License

TCTracking is available under the MIT license. See the LICENSE file for more info.
