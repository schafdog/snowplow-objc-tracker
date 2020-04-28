//
//  AgillicSDK.swift
//  SnowplowSwiftDemo
//
//  Created by Dennis Schafroth on 27/04/2020.
//  Copyright © 2020 snowplowanalytics. All rights reserved.
//

import Foundation
import SnowplowTracker

class AgillicSDK {
    private let urlFormat = "https://api%@-eu1.agillic.net";
    private var collectorEndpoint = "https://snowplowtrack-eu1.agillic.net";
    private var auth: Auth? = nil;
    private var methodType : SPRequestOptions = .post
    private var protocolType : SPProtocol = .http
    private var tracker: SPTracker?
    private var clientAppId: String = "N/A"
    private var clientAppVersion: String = "N/A"
    private var pushNotificationToken: String?
    private var registrationEndpoint: String?

    func setAuth(_ auth: Auth) {
        self.auth = auth;
    }
    
    func setAPI(_ api: String) {
        registrationEndpoint = String(format: urlFormat, api );
    }

    init() {
        setAPI("");
    }
    
    func setDevAPI() {
        setAPI("dev");
    }

    func setTestAPI() {
        setAPI("test");
    }
    
    func getTracker(_ url: String, method: SPRequestOptions, userId: String, appId: String) -> SPTracker {
        let emitter = SPEmitter.build({ (builder : SPEmitterBuilder?) -> Void in
            builder!.setUrlEndpoint(url)
            builder!.setHttpMethod(method)
            //builder!.setCallback(self)
            builder!.setProtocol(SPProtocol.https)
            builder!.setEmitRange(500)
            builder!.setEmitThreadPoolSize(20)
            builder!.setByteLimitPost(52000)
        })
        let subject = SPSubject(platformContext: true, andGeoContext: true)
        subject!.setUserId(userId)
        let newTracker = SPTracker.build({ (builder : SPTrackerBuilder?) -> Void in
            builder!.setEmitter(emitter)
            builder!.setAppId(appId)
            //builder!.setTrackerNamespace(self.kNamespace)
            builder!.setBase64Encoded(false)
            builder!.setSessionContext(true)
            builder!.setSubject(subject)
            builder!.setLifecycleEvents(true)
            builder!.setAutotrackScreenViews(true)
            builder!.setScreenContext(true)
            builder!.setApplicationContext(true)
            builder!.setExceptionEvents(true)
            builder!.setInstallEvent(true)
        })
        return newTracker!
    }


    func register(clientAppId: String, clientAppVersion: String,
                  solutionId: String, userID: String,
                  pushNotificationToken: String?) -> AgillicTracker
    {
        tracker = getTracker(collectorEndpoint, method: methodType, userId: userID, appId: solutionId)
        let agiTracker = AgillicTracker(tracker!);
        createMobileRegistration()
        return agiTracker;
        
    }
    
    func createMobileRegistration() {
        
        guard let endpointUrl = URL(string: registrationEndpoint!) else {
            return
        }
        
        //Make JSON to send to send to server
        let json : [String:String] = ["appInstallationId": tracker!.getSessionUserId(),
                                      "clientAppId": self.clientAppId,
                                      "clientAppVersion": self.clientAppVersion,
                                      "pushNotificationToken" :
                                        self.pushNotificationToken != nil ? self.pushNotificationToken! : "",
                                      "deviceModel": SPUtilities.getDeviceModel(),
                                      "modelDimX" :  SPUtilities.getResolution(),
                                      "modelDimY" :  SPUtilities.getResolution()]
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            var request = URLRequest(url: endpointUrl)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let task = URLSession.shared.dataTask(with: request)
            task.resume()

            
        }catch{
        }
    }
}

class Auth {
    
    func getAuthInfo() -> String {
        return "Not implemented";
    }
}

class BasicAuth : Auth {
    var authInfo: String
    init(user : String, password: String) {
        let userPw = user + ":" + password;
        authInfo = "Basic " + userPw.data(using: .utf8)!.base64EncodedString();
    }
    
    override func getAuthInfo() -> String {
        return authInfo;
    }
}
