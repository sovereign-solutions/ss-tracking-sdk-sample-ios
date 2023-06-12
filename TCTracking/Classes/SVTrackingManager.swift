//
//  SVTrackingManager.swift
//  SVTracking
//
//  Created by LAP01857 on 1/5/22.
//

import Foundation
import CoreLocation
import CoreMotion
public class SVTrackingManager: NSObject {
    public static let shareInstance = SVTrackingManager()
    var latitude: Double = 0
    var longitude: Double = 0
    var speed: Double = 0.0
    var heading: Double = 0.0
    var mCurrentLocation: CLLocation? = nil
    private var cacheParams: [[String : Any]] = []
    weak var delegate: OnResultListener? = nil
    // for timer tracking
    var backgroundUpdateTask: UIBackgroundTaskIdentifier =  UIBackgroundTaskInvalid
    var bgtimer: Timer?
    var locationManager = CLLocationManager()
    var db: TrackingDB? = nil
    var hasOfflineData = false
    private let DEFAULT_MAX_INTERVAL = 300
    private var maxInterval = 300
    private var lastSent = 0
    private let MOTION_UNKNOWN = 0
    private let MOTION_MOVING = 1
    private let MOTION_STATIONARY = 2
    private var motion = 0
    
    var mAccel: Double = 0
    var mAccelCurrent: Double = 0
    var mAccelLast: Double = 0
    
    var hitCount: Int = 0
    var hitSum: Double = 0
    var hitResult: Double = 0
    
    var SAMPLE_SIZE: Int = 150 // change this sample size as you want, higher is more precise but slow measure.
    var THRESHOLD: Double = 0.15 // change this threshold as you want, higher is more spike movement
    
    let motionManager = CMMotionManager()
    
    let motionActivityManager = CMMotionActivityManager()
    let IN_VEHICLE = 1 //    00000001    1    IN_VEHICLE    0    automotive
    let ON_BICYCLE = 2 //   00000010    2    ON_BICYCLE    1    cycling
    let ON_FOOT = 4 //    00000100    4    ON_FOOT    2
    let STILL = 8 //   00001000    8    STILL    3    stationrary
    let UNKNOWN = 16 //    00010000    16    UNKNOW    4    unknown    Default status
    let TILTING = 32 //   00100000    32    TILTING    5
    let WALKING = 64 //   01000000    64    WALKING    7    walking
    let RUNNING = 128 //   10000000    128
    var motionState = 16
    var shouldUpdateLoc = false
    
    public func setListener(listener: OnResultListener) {
        self.delegate = listener
    }
    
    var refreshTokenFailed = false
    var isSendingBigOfflineData = false
    var failedCount = 0
    var sendCount = 0
    var maxFail = 10
//    func sendLocation(_ location: CLLocationCoordinate2D, speed: Double, heading: Double) {
//        if (isSendingBigOfflineData) {
//            return;
//        }
//        if SVReachability.isConnectedToNetwork() {
//            NSLog("Internet Connection Available!")
//        } else {
//            NSLog("Internet Connection not Available!")
//            if (!cacheParams.isEmpty){
//                SVTrackingSession.shared.cacheData = cacheParams
//            }
//            return
//        }
//        if (!cacheParams.isEmpty) {
//            let driver = cacheParams[0]["driver"] as! String;
//            if (driver != SVTrackingSession.shared.userName) {
//                self.cacheParams.removeAll();
//                SVTrackingSession.shared.cacheData = self.cacheParams
//            } else {
//                if (SVTrackingSession.shared.deviceId!.contains("@")) {
//                    let trackerId = cacheParams[0]["trackerId"] as! String;
//                    if (trackerId != SVTrackingSession.shared.deviceId) {
//                        self.cacheParams.removeAll();
//                        SVTrackingSession.shared.cacheData = self.cacheParams
//                    }
//                }
//            }
//        }
//
//        if (cacheParams.isEmpty) {
//            var status = SVTrackingSession.shared.jobStatus
//            if (status == -5) {
//                status = speed > 1 ? 1 : 2
//            }
//
//            let params: [String : Any] = [
//                "driver": SVTrackingSession.shared.userName ?? "",
//                "heading":heading > 0 ? heading:0,
//                "jobStatus": status ?? 0,
//                "lat":location.latitude,
//                "lng":location.longitude,
//                "speed":speed > 0 ? speed:0,
//                "session": SVTrackingSession.shared.serviceTimestamp ?? 0,
//                "timestamp": Int64(Date().timeStamp),
//                "trackerId": SVTrackingSession.shared.deviceId,
//            ]
//            cacheParams.append(params)
//        }
//
//        let chunkSize = 100
//        let n = cacheParams.count
//        var sentSize = 0
//        if (chunkSize < n) {
//            isSendingBigOfflineData = true
//            for i in stride(from: 0, to: n, by: chunkSize) {
//                let j = min(n, i + chunkSize);
//                if (i >= j) {
//                    break;
//                }
//                let tmp = Array(cacheParams[i..<j])
//                let chunks = tmp as [[String: Any]]
//                let isSussess = sendData(locationData: chunks)
//                if (isSussess) {
//                    sentSize += chunks.count;
//                } else {
//                    break;
//                }
//            }
//            if (sentSize > 0) {
//                if (sentSize >= self.cacheParams.count) {
//                    self.cacheParams.removeAll();
//                } else {
//                    self.cacheParams.removeFirst(sentSize)
//                }
//                sentSize = 0;
//            }
//            SVTrackingSession.shared.cacheData = self.cacheParams
//            isSendingBigOfflineData = false
//        } else {
//            let isSuccess = sendData(locationData: cacheParams)
//            if (isSuccess) {
//                self.cacheParams.removeAll();
//            }
//            SVTrackingSession.shared.cacheData = self.cacheParams
//        }
//    }
//
    private func sendData(locationData:[[String:Any]], fromDB: Bool = true) -> Bool{
        var request = URLRequest(url: URL(string: "\(SVTrackingSession.shared.trackingURL ?? "")")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: locationData)
        request.addValue(SVTrackingSession.shared.accessToken ?? "", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let (data, _, _) = session.synchronousDataTask(urlrequest: request)
        guard let data = data else {
            return false
        }
        do {
            print(locationData)
            var json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if(json?["result"] != nil){
                NSLog("failed")
                NSLog(String(describing: json))
                if (json!["result"] as! Int == -2 && !refreshTokenFailed) {
                    refreshToken()
                    if (refreshTokenFailed) {
                        print("refresh failed")
                        return false
                    } else {
                        var request2 = URLRequest(url: URL(string: "\(SVTrackingSession.shared.trackingURL ?? "")")!)
                        request2.httpMethod = "POST"
                        request2.httpBody = try? JSONSerialization.data(withJSONObject: locationData)
                        request2.addValue(SVTrackingSession.shared.accessToken ?? "", forHTTPHeaderField: "Authorization")
                        request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        let (data2, _, _) = session.synchronousDataTask(urlrequest: request2)
                        if (data2 != nil) {
                            json = try JSONSerialization.jsonObject(with: data2!) as? [String: Any]
                        }
                    }
                }
            }
            let statuses = json?["status"] as? [[String: Any]]
            var isSuccess = false
            if (statuses != nil && statuses!.count > 0) {
                NSLog("success")
                isSuccess = statuses![0]["success"] as? Bool ?? false
            }
            NSLog(String(describing: json))
            json?["param"] = locationData
            json?["DB"] = fromDB ? "DB" : "RAM"
            json?["SUCCESS"] = isSuccess
            callback(result: json)
            return isSuccess
        } catch {
            NSLog("fail")
            print(error)
        }
        return false
    }
    
    func sendLocationDB(_ location: CLLocationCoordinate2D, speed: Double, heading: Double) {
        if (isSendingBigOfflineData) {
            return
        }
        if SVReachability.isConnectedToNetwork() {
            NSLog("Internet Connection Available!")
        } else {
            NSLog("Internet Connection not Available!")
            onSendFailed();
            return
        }
        if (hasOfflineData) {
            if (db == nil) {
                do {
                    try db = TrackingDB.open()
                } catch {
                }
            }
            var list = db?.getTrackingByUser(user: SVTrackingSession.shared.userName!) ?? []
            if (list.isEmpty) {
                hasOfflineData = false
            }
            
            let chunkSize = 100
            let n = list.count
            if (failedCount > 0) {
                var lastItemList : [[String : Any]] = []
                lastItemList.append(list[0])
                let success = sendData(locationData: lastItemList)
                if (success) {
                    lastSent = Int(Date().timeIntervalSince1970)
                    failedCount = 0
                } else {
                    if (failedCount < maxFail) {
                        failedCount = failedCount + 1
                    }
                    onSendFailed()
                    return
                }
            }
            if (chunkSize < n) {
                isSendingBigOfflineData = true
                for i in stride(from: 0, to: n, by: chunkSize) {
                    let j = min(n, i + chunkSize)
                    if (i >= j) {
                        break
                    }
                    let chunks = Array(list[i..<j])
                    let isSussess = sendData(locationData: chunks)
                    if (isSussess) {
                        lastSent = Int(Date().timeIntervalSince1970)
                        failedCount = 0
                        do {
                            try db?.deleteBefore(user: chunks.last!["driver"] as! String, time: chunks.last!["timestamp"] as! Int64)
                        } catch{
                        }
                    } else {
                        if (failedCount < maxFail) {
                            failedCount = failedCount + 1
                        }
                        onSendFailed()
                        break
                    }
                }
                isSendingBigOfflineData = false
            } else {
                let isSuccess = sendData(locationData: list)
                if (isSuccess) {
                    lastSent = Int(Date().timeIntervalSince1970)
                    failedCount = 0
                    do {
                        try db?.deleteBefore(user: list.last!["driver"] as! String, time: list.last!["timestamp"] as! Int64)
                    } catch{
                    }
                } else {
                    if (failedCount < maxFail) {
                        failedCount = failedCount + 1
                    }
                    onSendFailed()
                }
            }
            let tmpList = db?.getTrackingByUser(user: SVTrackingSession.shared.userName!) ?? []
            hasOfflineData = !tmpList.isEmpty
        }
        if (!hasOfflineData) {
            var isBuffer = false
            if (cacheParams.isEmpty) {
                if (Int(Date().timeIntervalSince1970) - lastSent < maxInterval) {
                    return
                }
                var status = SVTrackingSession.shared.jobStatus
                if (status == -5) {
                    status = speed > 1 ? 1 : 2
                }
                var params: [String : Any] = [
                    "driver": SVTrackingSession.shared.userName ?? "",
                    "heading": Double(heading > 0 ? heading:0),
                    "jobStatus": Int32(status ?? 0),
                    "lat":location.latitude,
                    "lng":location.longitude,
                    "speed": Double(speed > 0 ? speed:0),
                    "session": Int64(SVTrackingSession.shared.serviceTimestamp ?? 0),
                    "timestamp": Int64(Date().timeStamp),
                    "trackerId": SVTrackingSession.shared.deviceId,
                    "motionActivity": Int32(self.motionState),
                    "sourceType": "tracking-sdk"
                ]
                let motionActivity = params["motionActivity"] as? Int
                if (motionActivity != nil && motionActivity! < 0) {
                    params.removeValue(forKey: "motionActivity")
                }
                cacheParams.append(params)
                isBuffer = true
            }
            let isSuccess = sendData(locationData: cacheParams, fromDB: false)
            if (!isSuccess) {
                if (!isBuffer) {
                    onSendFailed()
                } else {
                    cacheParams.removeAll()
                }
            } else {
                cacheParams.removeAll()
            }
        }
    }
    
    private func refreshToken() {
        var request = URLRequest(url: URL(string: SVTrackingSession.shared.authenURL!)!)
        request.httpMethod = "POST"
        let body = "grant_type=refresh_token&refresh_token=" + SVTrackingSession.shared.refreshToken!
        request.httpBody = Data(body.utf8)
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let (data, _, _) = session.synchronousDataTask(urlrequest: request)
        guard let data = data else { return }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if(json?["result"] != nil){
                print("failed")
            } else {
                SVTrackingSession.shared.accessToken = json?["access_token"] as? String
                SVTrackingSession.shared.refreshToken = json?["refresh_token"] as? String
                let seconds = json?["expires_in"] as? Int64
                SVTrackingSession.shared.tokenExpires = String(((seconds ?? 86399) + Int64(Date().timeIntervalSince1970)) * 1000)
            }
            NSLog("RefreshToken " + String(describing: json))
//            print(SVTrackingSession.shared.accessToken)
//            print(SVTrackingSession.shared.refreshToken)
//            print(SVTrackingSession.shared.tokenExpires)
        } catch {
            print("fail")
            print(error)
            refreshTokenFailed = true
        }
    }
    public func configData(driverName: String, accessToken: String, trackingURL: String, backendURL: String, apiVersion: String, jobStatus : Int) {
        SVTrackingSession.shared.userName = driverName
        SVTrackingSession.shared.trackingURL = trackingURL
        SVTrackingSession.shared.backendURL = backendURL
        SVTrackingSession.shared.accessToken = accessToken
        SVTrackingSession.shared.version = apiVersion
        SVTrackingSession.shared.jobStatus = jobStatus
    }
    
    public func setDeviceId(id: String) {
        SVTrackingSession.shared.deviceId = id
    }
    
    // timer tracking here
    @objc func bgtimer(_ timer: Timer!) {
        if SVTrackingSession.shared.accessToken == nil {
            bgtimer?.invalidate()
            bgtimer = nil
            return
        }
        if (failedCount > 0 && sendCount < failedCount) {
            sendCount = sendCount + 1
        } else {
            sendCount = 0
            SVTrackingManager.shareInstance.sendLocationDB(CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), speed: self.speed, heading: self.heading)
        }
    }
    
    public func isTracking() -> Bool {
        return SVTrackingSession.shared.isTracking ?? false
    }
    
    public func enableService() {
        SVTrackingSession.shared.isTracking = true
        if (SVTrackingSession.shared.serviceTimestamp == 0) {
            SVTrackingSession.shared.serviceTimestamp = Date().timeStamp
        }
        doBackgroundTask()
    }
    
    public func disableService() {
        bgtimer?.invalidate()
        bgtimer = nil
        SVTrackingSession.shared.isTracking = false
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        SVTrackingSession.shared.serviceTimestamp = 0
    }
    
    public func setTrackingStatus(jobStatus: NSInteger) {
        SVTrackingSession.shared.jobStatus = jobStatus
    }
    
    public func setTrackingFrequency(miliseconds: Int) {
        SVTrackingSession.shared.trackingFrequency = miliseconds
    }
    
    public func setAuthenInfo(url: String, refreshToken: String, expiresIn: String) {
        if (SVTrackingSession.shared.authenURL == nil || SVTrackingSession.shared.refreshToken == nil) {
            SVTrackingSession.shared.authenURL = url
            SVTrackingSession.shared.refreshToken = refreshToken
            SVTrackingSession.shared.tokenExpires = expiresIn
        } else {
            if (SVTrackingSession.shared.authenURL == url) {
                let exp = Int64(expiresIn) ?? 0
                let tmp = (Int64(SVTrackingSession.shared.tokenExpires ?? "0") ?? 0)
                NSLog("Expired Time Compare " + String(exp) + " " + (String(tmp)))
                if (exp >= tmp) {
                    SVTrackingSession.shared.refreshToken = refreshToken
                    SVTrackingSession.shared.tokenExpires = expiresIn
                }
            } else {
                SVTrackingSession.shared.authenURL = url
                SVTrackingSession.shared.refreshToken = refreshToken
                SVTrackingSession.shared.tokenExpires = expiresIn
            }
        }
    }
    
    public func setUseMotionSensor(enable: Bool) {
        SVTrackingSession.shared.useMotionSensor = enable
    }
    
    func callback(result: Any) {
        delegate?.onResult(result: result)
    }
    
    func doBackgroundTask() {
        DispatchQueue.global().async {
            self.beginBackgroundUpdateTask()
            self.startupdateLocation()
            // timer
            if self.bgtimer != nil {
                self.bgtimer?.invalidate()
                self.bgtimer = nil
            }
            let ti = SVTrackingSession.shared.trackingFrequency! / 1000
            self.maxFail = 60 / ti * 10
            self.bgtimer = Timer.scheduledTimer(timeInterval: TimeInterval(ti), target: self, selector: #selector(self.bgtimer(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(self.bgtimer!, forMode: RunLoop.Mode.defaultRunLoopMode)
            RunLoop.current.run()
            
            self.endBackgroundUpdateTask()
        }
    }
    
    func beginBackgroundUpdateTask() {
        backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }

    private override init() {
        super.init()
        locationManager.delegate = self
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        let ti = SVTrackingSession.shared.trackingFrequency! / 1000
        maxInterval = DEFAULT_MAX_INTERVAL - ti
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 20
        if (db == nil){
            do {
                try db = TrackingDB.open()
                try db?.createTable()
            } catch {
            }
        }
        let list = db?.getTrackingByUser(user: SVTrackingSession.shared.userName!) ?? []
        hasOfflineData = !list.isEmpty
    }
    
    func startupdateLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges();
        if (SVTrackingSession.shared.useMotionSensor == true) {
            if (CMMotionActivityManager.isActivityAvailable()) {
                motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
                    var state = 0
                    var isMoving = false
                    guard let activity = activity else {
                        return
                    }
                    if activity.walking {
                        state = state | self.WALKING
                        isMoving = true
                    }
                    
                    if activity.running {
                        state = state | self.RUNNING
                        isMoving = true
                    }
                    
                    if activity.cycling {
                        state = state | self.ON_BICYCLE
                        isMoving = true
                    }
                    
                    if activity.automotive {
                        state = state | self.IN_VEHICLE
                        isMoving = true
                    }
                    
                    if activity.stationary {
                        state = state | self.STILL
                        isMoving = false
                    }
                    
                    if (activity.unknown) {
                        state = state | self.UNKNOWN
                        isMoving = false
                    }
                    if (state != 0 && activity.confidence != CMMotionActivityConfidence.low) {
                        self.motionState = state
                        if (isMoving) {
                            self.shouldUpdateLoc = true
                        }
                    }
                    print(activity.confidence == CMMotionActivityConfidence.high ? "high" : activity.confidence == CMMotionActivityConfidence.medium ? "medidium" : "low")
                    print(state)
                }
            }
        } else {
            self.motionState = -1;
        }
//            if (motionManager.isAccelerometerAvailable) {
//                print("AccelerometerAvailable")
//                motionManager.accelerometerUpdateInterval = 1.0 / 50.0
//                let queue = OperationQueue()
//                motionManager.startAccelerometerUpdates(to: queue, withHandler: { [self]
//                    data, error in guard let data = data else { return }
//                    let x = data.acceleration.x
//                    let y = data.acceleration.y
//                    let z = data.acceleration.z
//
//                    self.mAccelLast = self.mAccelCurrent;
//                    self.mAccelCurrent = sqrt(x * x + y * y + z * z);
//                    let delta = self.mAccelCurrent - self.mAccelLast;
//                    self.mAccel = self.mAccel * 0.9 + delta;
//                    if (self.hitCount <= SAMPLE_SIZE) {
//                                hitCount += 1
//                                hitSum += abs(mAccel)
//                    } else {
//                        hitResult = hitSum / Double(SAMPLE_SIZE);
//
//                        print(String(hitResult))
//
//                        if (hitResult > THRESHOLD) {
//                            //print("Moving")
//                            motion = MOTION_MOVING;
//                        } else {
//                            //print("Stationary")
//                            motion = MOTION_STATIONARY
//                        }
//
//                        hitCount = 0;
//                        hitSum = 0;
//                        hitResult = 0;
//                    }
//                })
//            }
//        } else {
//            print("Not using Sensor")
//        }
    }
    
    func onSendFailed() {
        if (db == nil){
            do {
                try db = TrackingDB.open()
            } catch {
            }
        }
        if (db != nil) {
            if (cacheParams.isEmpty) {
                return;
            }
            db?.insertMulti(params: cacheParams)
            hasOfflineData = true;
            cacheParams.removeAll()
        }
    }
}

extension SVTrackingManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while requesting new coordinates")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last
        if (loc == nil) { return }
        if (SVTrackingSession.shared.useMotionSensor == true && (motionState & STILL == STILL) && self.mCurrentLocation != nil) {
            if (loc!.horizontalAccuracy < mCurrentLocation!.horizontalAccuracy) {
                shouldUpdateLoc = true;
            }
            if (!shouldUpdateLoc) {
                print("skip location")
                return;
            }
        }
        shouldUpdateLoc = false
        
        self.mCurrentLocation = loc
        self.latitude = loc!.coordinate.latitude
        self.longitude = loc!.coordinate.longitude
        self.speed = manager.location?.speed ?? 0.0
        self.heading = manager.location?.course ?? 0.0
        
        var status = SVTrackingSession.shared.jobStatus
        if (status == -5) {
            status = speed > 1 ? 1 : 2
        }
        var params: [String : Any] = [
            "driver": SVTrackingSession.shared.userName ?? "",
            "heading":Double(heading > 0 ? heading:0),
            "jobStatus": Int32(status ?? 0),
            "lat":loc!.coordinate.latitude,
            "lng":loc!.coordinate.longitude,
            "speed": Double(speed > 0 ? speed:0),
            "session": Int64(SVTrackingSession.shared.serviceTimestamp ?? 0),
            "timestamp": Int64(Date().timeStamp),
            "trackerId": SVTrackingSession.shared.deviceId!,
            "motionActivity": Int32(self.motionState),
            "sourceType": "tracking-sdk"
        ]
        let motionActivity = params["motionActivity"] as? Int32
        if (motionActivity != nil && motionActivity! < 0) {
            params.removeValue(forKey: "motionActivity")
        }
        self.cacheParams.append(params)
            
//            let trackingParam = TrackingDB.TrackingParam(
//                timestamp: Int64(Date().timeStamp),
//                heading: heading > 0 ? Float(heading) : 0,
//                lat: locValue.latitude,
//                lng: locValue.longitude,
//                speed: speed > 0 ? speed : 0,
//                driver: SVTrackingSession.shared.userName ?? "",
//                trackerId: SVTrackingSession.shared.deviceId!,
//                jobStatus: status ?? 0,
//                session: Int64(SVTrackingSession.shared.serviceTimestamp ?? 0),
//                motionActivity: self.motionState
//            )
//            if (db == nil){
//                do {
//                    try db = TrackingDB.open()
//                } catch {
//                }
//            }
//            if (db != nil) {
//                do {
//                    try db?.insertParam(param: trackingParam)
//                } catch {
//                }
//            }
        
    }
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}
@objc public protocol OnResultListener {
    func onResult(result: Any)
}
