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
    func getSnowplowEvent() -> SPEvent? {
        return nil
    }
    
    var screenId: String
    var screenName: String
    
    init(_ screenId: String, screenName: String? = nil) {
        self.screenId = screenId;
        self.screenName = screenName != nil ? screenName! : screenId;
    }
    
    func getSnowplowEvent() -> SPScreenView? {
        let event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            builder!.setName(self.screenName)
            builder!.setScreenId(self.screenId)
        })
        return event;
    }

    func track(_ tracker: AgillicTracker) {
        track(tracker.tracker)
    }

    func track(_ tracker: SPTracker) {
        let event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            builder!.setName(self.screenName)
            builder!.setScreenId(self.screenId)
        })
        tracker.trackScreenViewEvent(event)
    }

}
