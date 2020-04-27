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
    private let urlFormat = "https://api%s-eu1.agillic.net";
    private var url: String?;
    private var collectorEndpoint = "https://snowplowtrack-eu1.agillic.net";
    private var auth: BasicAuth? = nil;
    private var methodType : SPRequestOptions = .post
    private var protocolType : SPProtocol = .http

    func setAPI(_ api: String) {
        url = String(format: urlFormat, api );
    }

    init(url: String) {
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


    func register(appID: String, clientAppId: String, clientAppVersion: String,
                  userID: String, pushNotificationToken: String) -> AgillicTracker
    {
        let tracker = getTracker(collectorEndpoint, method: methodType, userId: userID, appId: appID)
        let agiTracker = AgillicTracker(tracker);
        
        return agiTracker;
        
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
