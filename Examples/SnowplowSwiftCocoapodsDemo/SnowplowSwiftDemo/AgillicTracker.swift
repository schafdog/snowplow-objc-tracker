//
//  AgillicTracker.swift
//  SnowplowSwiftDemo
//
//  Created by Dennis Schafroth on 27/04/2020.
//  Copyright © 2020 snowplowanalytics. All rights reserved.
//

import Foundation
import SnowplowTracker


class AgillicTracker  {
    var tracker: SPTracker
    var enabled = true

    init(_ tracker: SPTracker) {
        self.tracker = tracker
    }
    
    func track(_ event : AgillicEvent) {
        if (enabled) {
            event.track(tracker)
        }
    }
    
    func getSPTracker() -> SPTracker {
        return tracker
    }

    func pauseTracking() {
        enabled = false
    }

    func resumeTracking() {
        enabled = false
    }
    
    func isTracking() -> Bool {
        return enabled
    }
}
