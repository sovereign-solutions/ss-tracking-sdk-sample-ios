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
        let user = "thanh13"
        let token = "bearer f0ue9Ce6swJXku2IH8h_....."
        let refreshToken = "rvFTI9O9oXggF6FeqvIxbWaeno57aax....."
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

        SVTrackingManager.shareInstance.configData(driverName: user, accessToken: token, trackingURL: "https://testing.skedulomatic.com/api/app-base/vdms-tracking/push", backendURL: "https://testing.skedulomatic.com", apiVersion: "2.7.2", jobStatus: 2)
        SVTrackingManager.shareInstance.setTrackingFrequency(miliseconds: 10000)
        SVTrackingManager.shareInstance.setAuthenInfo(url:"https://accounts.skedulomatic.com/oauth/token", refreshToken: refreshToken, expiresIn:String(expiresIn))
        SVTrackingManager.shareInstance.setUseMotionSensor(enable: true)
        SVTrackingManager.shareInstance.enableService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

