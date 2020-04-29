//
//  ScreenViewEvent.swift
//  SnowplowSwiftDemo
//
//  Created by Dennis Schafroth on 27/04/2020.
//  Copyright © 2020 snowplowanalytics. All rights reserved.
//

import Foundation
import SnowplowTracker

class PushNotification : AgillicEvent {
    var screenId: String
    var screenName: String
    var type: String?
    var previousScreenId: String?
    
    init(_ screenId: String, screenName: String? = nil, type: String? = nil, previousScreenId: String? = nil) {
        self.screenId = screenId
        self.screenName = screenName != nil ? screenName! : screenId
        self.type = type
        self.previousScreenId = previousScreenId
    }
    
    func getSnowplowEvent() -> SPPushNotification? {
        let event = SPPushNotification.build({(builder : SPPushNotificationBuilder?) -> Void in
            builder!.setTrigger("PUSH") // can be "PUSH", "LOCATION", "CALENDAR", or "TIME_INTERVAL"
            builder!.setAction("action")
            builder!.setDeliveryDate("date")
            builder!.setCategoryIdentifier("category")
            builder!.setThreadIdentifier("thread")
            // builder!.setNotification(content)
        })
        return event;
    }

    func track(_ tracker: AgillicTracker) {
        track(tracker.tracker)
    }

    func track(_ tracker: SPTracker) {
        //tracker.trackPushNotification(getSnowplowEvent())
    }

}
