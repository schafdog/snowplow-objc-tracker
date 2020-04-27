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
    
    init(_ tracker: SPTracker) {
        self.tracker = tracker
    }
    
    func track(_ event : AgillicEvent) {
        event.track(tracker)
    }


}
