//
//  ScreenViewEvent.swift
//  SnowplowSwiftDemo
//
//  Created by Dennis Schafroth on 27/04/2020.
//  Copyright © 2020 snowplowanalytics. All rights reserved.
//

import Foundation
import SnowplowTracker

class AppViewEvent : AgillicEvent {
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
    
    func getSnowplowEvent() -> SPScreenView? {
        let event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            builder!.setName(self.screenName)
            builder!.setScreenId(self.screenId)
            builder!.setType(self.type)
            builder!.setPreviousScreenId(self.previousScreenId)
        })
        return event;
    }

    func track(_ tracker: AgillicTracker) {
        track(tracker.tracker)
    }

    func track(_ tracker: SPTracker) {
        tracker.trackScreenViewEvent(getSnowplowEvent())
    }

}
