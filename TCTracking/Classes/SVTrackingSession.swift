//
//  SVTrackingSession.swift
//  SVTracking
//
//  Created by LAP01857 on 1/5/22.
//

import Foundation

public class SVTrackingSessionConstant {
    static var userName         = "key_userName"
    static var keyTimestamp     = "key_timestamp"
    static var keyTrackingURL   = "key_trackingurl"
    static var keyBackendURL    = "key_backendurl"
    static var keyVersion       = "key_version"
    static var keyAcccessToken  = "key_access_token"
    static var keyJobStatus  = "key_job_status"
    static var keyIsTracking  = "key_is_tracking"
    static var keyDeviceId = "key_device_id"
    static var keyTrackingFrequency = "key_tracking_frequency"
    static var keyCacheData = "key_cache_data"
    static var keyRefreshToken = "key_refresh_token"
    static var keyAuthenURL = "key_authen_url"
    static var keyTokenExpires = "key_token_expires"
    static var keySession = "key_session"
    static var keyUseMotionSensor = "key_use_motion_sensor"
}

public class SVTrackingSession: NSObject {
   
    static let shared = SVTrackingSession()
    
    override init() {
        super.init()
        self.loadDefault()
    }
    
    var userName: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.userName)
        } set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.userName)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.userName)
            }
        }
    }
    
    var serviceTimestamp: Int? {
        get {
            return UserDefaults.standard.integer(forKey: SVTrackingSessionConstant.keyTimestamp)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyTimestamp)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyTimestamp)
            }
        }
    }
    // handle tracking url
    var trackingURL: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.keyTrackingURL)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyTrackingURL)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyTrackingURL)
            }
        }
    }
    
    // handle backend url
    var backendURL: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.keyBackendURL)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyBackendURL)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyBackendURL)
            }
        }
    }
    
    var version: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.keyVersion)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyVersion)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyVersion)
            }
        }
    }
    
    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.keyAcccessToken)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyAcccessToken)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyAcccessToken)
            }
        }
    }
    
    var jobStatus: Int? {
        get {
            return UserDefaults.standard.integer(forKey: SVTrackingSessionConstant.keyJobStatus)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyJobStatus)
        }
    }
    
    var isTracking: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: SVTrackingSessionConstant.keyIsTracking)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyIsTracking)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyIsTracking)
            }
        }
    }
    
    var deviceId: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.keyDeviceId)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyDeviceId)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyDeviceId)
            }
        }
    }
    
    var trackingFrequency: Int? {
        get {
            return UserDefaults.standard.integer(forKey: SVTrackingSessionConstant.keyTrackingFrequency)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyTrackingFrequency)
        }
    }
    
//    var cacheData: [[String: Any]]? {
//        get {
//            let key = (userName != nil && !userName!.isEmpty) ? "key_cache_\(userName ?? "")" : SVTrackingSessionConstant.keyCacheData
//            return UserDefaults.standard.array(forKey: key) as? [[String: Any]]
//        }
//        set {
//            let key = (userName != nil && !userName!.isEmpty) ? "key_cache_\(userName ?? "")" : SVTrackingSessionConstant.keyCacheData
//            UserDefaults.standard.set(newValue, forKey: key)
//        }
//    }
    
    var authenURL: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.keyAuthenURL)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyAuthenURL)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyAuthenURL)
            }
        }
    }
    
    var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.keyRefreshToken)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyRefreshToken)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyRefreshToken)
            }
        }
    }
    
    var tokenExpires: String? {
        get {
            return UserDefaults.standard.string(forKey: SVTrackingSessionConstant.keyTokenExpires)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyTokenExpires)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyTokenExpires)
            }
        }
    }
    
    var useMotionSensor: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: SVTrackingSessionConstant.keyUseMotionSensor)
        }
        set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: SVTrackingSessionConstant.keyUseMotionSensor)
            } else {
                UserDefaults.standard.removeObject(forKey: SVTrackingSessionConstant.keyUseMotionSensor)
            }
        }
    }
    
    var dbVersion: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "db_version")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "db_version")
        }
    }
    
    func loadDefault() {
        let userDef = UserDefaults.standard
        self.userName = userDef.string(forKey: SVTrackingSessionConstant.userName) ?? ""
        self.serviceTimestamp = userDef.integer(forKey: SVTrackingSessionConstant.keySession)
        self.trackingURL = userDef.string(forKey: SVTrackingSessionConstant.keyTrackingURL) ?? ""
        self.backendURL = userDef.string(forKey: SVTrackingSessionConstant.keyBackendURL) ?? ""
        self.version = userDef.string(forKey: SVTrackingSessionConstant.keyVersion) ?? ""
        self.accessToken = userDef.string(forKey: SVTrackingSessionConstant.keyVersion) ?? nil
        self.jobStatus = userDef.integer(forKey: SVTrackingSessionConstant.keyJobStatus)
        self.isTracking = userDef.bool(forKey: SVTrackingSessionConstant.keyIsTracking)
        self.deviceId = userDef.string(forKey: SVTrackingSessionConstant.keyDeviceId) ?? UIDevice.current.identifierForVendor?.uuidString
        self.trackingFrequency = userDef.integer(forKey: SVTrackingSessionConstant.keyTrackingFrequency)
        if (self.trackingFrequency! <= 0) {
            self.trackingFrequency = 10000;
        }
        self.authenURL = userDef.string(forKey: SVTrackingSessionConstant.keyAuthenURL) ?? nil
        self.refreshToken = userDef.string(forKey: SVTrackingSessionConstant.keyRefreshToken) ?? nil
        self.tokenExpires = userDef.string(forKey: SVTrackingSessionConstant.keyTokenExpires) ?? "0"
        self.useMotionSensor = userDef.bool(forKey: SVTrackingSessionConstant.keyUseMotionSensor)
        self.dbVersion = userDef.integer(forKey: "db_version")
    }
}

extension Date {
    var timeStamp: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return timeStamp*1000
    }
}
