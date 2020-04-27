//
//  AgillicEvent.swift
//  SnowplowSwiftDemo
//
//  Created by Dennis Schafroth on 27/04/2020.
//  Copyright © 2020 snowplowanalytics. All rights reserved.
//

import Foundation
import SnowplowTracker

protocol AgillicEvent {
    func getSnowplowEvent() -> SPEvent?;
    func track(_ tracker: AgillicTracker);
    func track(_ tracker: SPTracker);
}
