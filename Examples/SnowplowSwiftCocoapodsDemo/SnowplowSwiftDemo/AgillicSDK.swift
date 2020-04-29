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
    private var collectorEndpoint = "localhost:9090";
    private var auth: Auth? = nil;
    private var methodType : SPRequestOptions = .post
    private var protocolType : SPProtocol = .http
    private var tracker: SPTracker?
    private var clientAppId: String = "N/A"
    private var clientAppVersion: String = "N/A"
    private var pushNotificationToken: String?
    private var registrationEndpoint: String?
    private var userId: String?
    private var count = 0

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
            builder!.setProtocol(SPProtocol.http)
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
        self.clientAppId = clientAppId
        self.clientAppVersion = clientAppVersion
        // self.solutionId
        self.userId = userID
        self.pushNotificationToken = pushNotificationToken

        tracker = getTracker(collectorEndpoint, method: methodType, userId: userID, appId: solutionId)
        let agiTracker = AgillicTracker(tracker!);
        createMobileRegistration()
        return agiTracker;
        
    }
    
    func createMobileRegistration() {
        let fullRegistrationUrl = String(format: "%@/register/%@", self.registrationEndpoint!, self.userId!)
        guard let endpointUrl = URL(string: fullRegistrationUrl) else {
            NSLog("Failed to create registration URL %@", fullRegistrationUrl)
            return
        }
        
        //Make JSON to send to send to server
        let json : [String:String] = ["appInstallationId": tracker!.getSessionUserId(),
                                      "clientAppId": self.clientAppId,
                                      "clientAppVersion": self.clientAppVersion,
                                      "pushNotificationToken" :
                                        self.pushNotificationToken != nil ? self.pushNotificationToken! : "",
                                      "deviceModel": SPUtilities.getDeviceModel(),
                                      "modelDimX" :  getXDimension(SPUtilities.getResolution()),
                                      "modelDimY" :  getYDimension(SPUtilities.getResolution())]
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            // Convert to a string and print
            if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
               NSLog("Registration JSON: %@", JSONString)
            }
    
            var request = URLRequest(url: endpointUrl)
            let authorization = auth!.getAuthInfo()
            request.httpMethod = "PUT"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(authorization, forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                if let error = error {
                    NSLog("Failed to register: %@", error.localizedDescription)
                    self!.count += 1;
                    if self!.count < 3 {
                        sleep(2000)
                        self!.createMobileRegistration()
                    }
                } else {
                    let response = response as? HTTPURLResponse
                    NSLog("Register: %d", response!.statusCode)
                }
            })
            task.resume()
            NSLog("Registration sendt")
        } catch{
            NSLog("Registration Exception")
        }
    }
    
    func getXDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.first ?? "?")
    }

    func getYDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.last ?? "?")
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
