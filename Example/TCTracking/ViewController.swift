//
//  ViewController.swift
//  TCTracking
//
//  Created by PhuTruong on 06/08/2023.
//  Copyright (c) 2023 PhuTruong. All rights reserved.
//

import UIKit
import TCTracking
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = "sales_testing_2"
        let token = "bearer KZXSGea-e8LQhZS-Mf-MMk6eLaoFw1eS_aBttGsnG-_PZ3vBHcxgXxS1z-mQDcsmxnlCV-Y7As6Ui8Gyw65f6vQBOmtFF0DhnwWX5X3BKBt6sGgtuWuQHF4VTYMo-HTHdZ9WatXghvddWTsJcxjLIcVKmzFYYmXblIo3gUS2Cu2Kp8wECsYXpS-xqk9RLrugjExnQjI7Xbv7jhi3hdEftY9O2xIN4XFenSJ0-SqqqzlWw6W8tVomKbKQG1PLQ0DY8DfFAmwEkYhEuiyznZ2jhYOBMAKBzVFgDfPH6O98mnjkS6tW_viSYP4SzOxWQpwucr9SSlDBTW7EcZYSYsPcjjMTR_mMqBV8psZXuRIPFL2zsIqXyIMPjMnQoIIycpPEL5k3iKQuG8hlGyrjDz5EwZEpXVvzSBAkaVijbMMrM7EgCU2qwfATs5kITWe2aUMi1FoJTJF-mFBR5XqynnrcqdrD94o"
        let refreshToken = "9s5VvQRZPMwvT_Zfs_eTzsvmcWWxs7gwq5dZ2gOL3oyNTqIw9XeB3mAeY5ogxfJiHRGsQFC7YaPrtMrfnP7PyR9qUG-JLxfiLo0w9eZkZAQ1h2OYTnIGp1Ksd9dD4pI1mAL_zE9wnukZVam3edsEESKPxwNMe1FZybzI31d0FS78P9LrJzHZbhEn2MLosn5hYSU-h7zn5o-HmmmIu5c7M2l4vPX0O04F3iQO9zwz0WsrLPumu5FWt6KYRofcGmKh17CuuSSAIAQEwl1icHTMeMGNcbWZ7mDYAsGQpCFghglJDbC_5-U35qtYjL0kCsKKHcEUI0vvuQ6sZVG96koUIIZhvTHMZ-VQzmGO5xq8AnZ-gJH_MXgVW6ZHQzYjCQKN-UEQOBZiG5BwPUUMORy9kaZt4BTwSp9CTCixtf4XU9jBBoPu69xNaZIWAYxbqI7Yl5jt9f8nJQijYWKKE3dHPBalF0o"
//        let expiresIn = expires_in + Date().timeIntervalSince1970
        let expiresIn = 0
//    ApiUrl: HOST + "/api/app-base/vdms-tracking/push" // https://testing.skedulomatic.com/api/app-base/vdms-tracking/push
//    LoginUrl: AUTHURL + "/oauth/token"                // https://accounts.skedulomatic.com/oauth/token
//        use the LoginUrl with your username and password to get the `token`, `refreshToken`
//        `curl --location 'https://accounts.skedulomatic.com/oauth/token' \
//        --header 'Content-Type: application/x-www-form-urlencoded' \
//        --data-urlencode 'grant_type=password' \
//        --data-urlencode 'username=<username>' \
//        --data-urlencode 'password=<password>'

        SVTrackingManager.shareInstance.config(driverName: user, accessToken: token, trackingURL: "https://sales.grow-matic.com/api/app-base/vdms-tracking/push", backendURL: "https://testing.skedulomatic.com", jobStatus: 2)
        SVTrackingManager.shareInstance.setTrackingFrequency(miliseconds: 10000)
        SVTrackingManager.shareInstance.setAuthenInfo(url:"https://accounts.skedulomatic.com/oauth/token", refreshToken: refreshToken, expiresIn:String(expiresIn))
        SVTrackingManager.shareInstance.setUseMotionSensor(enable: true)
        //set TrackerId
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "" as String
        SVTrackingManager.shareInstance.setDeviceId(id:"\(deviceId)@\(user)")
        //set device status (1: active, 2: idle)
        //SVTrackingManager.shareInstance.setTrackingStatus(2)

        SVTrackingManager.shareInstance.enableService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

