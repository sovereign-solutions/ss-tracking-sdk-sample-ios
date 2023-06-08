//
//  SVTrackingNetworkManager.swift
//  SVTracking
//
//  Created by LAP01857 on 1/5/22.
//

import Foundation
import Foundation
import UIKit
import Alamofire
import SwiftyJSON

public class SVTrackingNetworkManager: NSObject {
    
    static let shareInstance = SVTrackingNetworkManager()
    private var sessionManager = SessionManager()
    typealias SuccessHandler = (Any) -> Void
    typealias FailureHandler = (Error) -> Void
    
    override init() {
        super.init()
        // configuration network
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.sessionManager = Alamofire.SessionManager(configuration: config)
    }
    
    private func getHeader(enableHeader: Bool) -> HTTPHeaders? {
        if enableHeader {
            return ["Authorization": "bearer "+(SVTrackingSession.shared.accessToken ?? ""),
                    "Content-Type": "application/json"]
        }
        return ["Content-Type": "application/json"]
    }
    
    func requestAPI(_ endpoint: String, params: [String: Any]? = nil, isFullLink: Bool? = nil, method: HTTPMethod, enableHeader: Bool? = nil, printDebug: Bool? = nil, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        var urlString = ""
        if isFullLink == true {
            urlString = endpoint
        } else {
            urlString = "\(SVTrackingSession.shared.backendURL ?? "")\(endpoint)"
        }
        
        self.sessionManager.request(urlString, method: method, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader(enableHeader: enableHeader ?? false)).responseJSON { (response) in
            if printDebug == true {
                debugPrint(urlString)
                debugPrint(response)
                debugPrint(params ?? [])
            }
            if response.result.isSuccess, let value = response.result.value {
                let json = JSON(value)
                var errorString = json["errorMessage"].stringValue
                if errorString.uppercased() == "Bạn không đủ quyền truy cập tài nguyên này".uppercased() {
                    NotificationCenter.default.post(name: NOTIFICATION_NAME.invalidToken, object: nil)
                } else if let errorObject = json["errorMessage"].arrayObject, errorString.isEmpty {
                    for object in errorObject {
                        if let dicValue: NSDictionary = object as? NSDictionary, let errorM: String = dicValue.allValues.first as? String {
                            errorString = errorM
                            break
                        }
                    }
                } else if !errorString.isEmpty {
                    let error = NSError(domain: errorString, code: 500, userInfo: [:])
                    failure(error)
                }
                
                let code = json["status"]["code"].intValue
                if code == 401 {
                    // logout
                    NotificationCenter.default.post(name: NOTIFICATION_NAME.invalidToken, object: nil)
                } else if !errorString.isEmpty {
                    let error = NSError(domain: errorString, code: 500, userInfo: [:])
                    failure(error)
                } else {
                    success(value)
                }
            } else {
                // network error
                if let error: Error = response.result.error {
                    self.internetConnectionFaild(error: error as NSError)
                    failure(error)
                } else {
                    let error = NSError(domain: "Có lỗi xảy ra", code: 600, userInfo: [:])
                    failure(error)
                }
            }
        }
    }
    
    private func processError(error: NSError) {
        if error.code == ERROR_CODE.invalidToken {
            NotificationCenter.default.post(name: NOTIFICATION_NAME.invalidToken, object: nil)
        }
    }
    
    private func internetConnectionFaild(error: NSError) {
        if error.code == ERROR_CODE.notConnection {
            NotificationCenter.default.post(name: NOTIFICATION_NAME.internetConnectionFaild, object: nil)
        }
    }
    
    func trackingOffLine(_ endPoint: URL, values: [[String : Any]], success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        var request = URLRequest(url: endPoint)
        request.httpMethod = "POST"
        request.addValue("bearer "+(SVTrackingSession.shared.accessToken ?? ""), forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    }
                    failure(error)
                case .success(let responseObject):
                    success(responseObject)
                }
            }
    }
}

class NOTIFICATION_NAME {
    // server business
    static let invalidToken = NSNotification.Name(rawValue: "NTF_INVALID_TOKEN")
    static let internetConnectionFaild = NSNotification.Name(rawValue: "NTF_INTERNET_CONNECTION_FAILD")
}

class ERROR_CODE {
    static let invalidToken = 401
    static let notConnection = -1009
}
