//
//  ViewController.swift
//  SnowplowSwiftDemo
//
//  Created by Michael Hadam on 1/17/18.
//  Copyright © 2018 snowplowanalytics. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import SnowplowTracker

// Used for all child views
protocol PageObserver: class {
    func getParentPageViewController(parentRef: PageViewController)
}

class DemoViewController: UIViewController, UITextFieldDelegate, PageObserver {
    private let keyUriField = "URL-Endpoint";

    @IBOutlet weak var uriField: UITextField!
    @IBOutlet weak var trackingSwitch: UISegmentedControl!
    @IBOutlet weak var protocolSwitch: UISegmentedControl!
    @IBOutlet weak var methodSwitch: UISegmentedControl!
    weak var tracker : AgillicTracker?

    var parentPageViewController: PageViewController!
    @objc dynamic var snowplowId: String! = "demo view"

    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
        tracker = parentRef.tracker
    }

    @objc func action() {
        
        let tracking: Bool = (trackingSwitch.selectedSegmentIndex == 0)
        if (tracking && !(tracker?.isTracking() ?? false)) {
            tracker?.resumeTracking()
        } else if (tracker?.isTracking() ?? false) {
            tracker?.pauseTracking()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.parentPageViewController.uri = uriField.text!
        return textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uriField.delegate = self
        self.trackingSwitch.addTarget(self, action: #selector(action), for: .valueChanged)
        // Do any additional setup after loading the view, typically from a nib.
        uriField.text = UserDefaults.standard.string(forKey: keyUriField) ?? ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func inputUri(_ sender: UITextField) {
        self.parentPageViewController.uri = uriField.text!
    }
    
    @IBAction func toggleMethod(_ sender: UISegmentedControl) {
        self.parentPageViewController.methodType = (methodSwitch.selectedSegmentIndex == 0) ?
            .get : .post
    }
    
    @IBAction func toggleProtocol(_ sender: UISegmentedControl) {
        self.parentPageViewController.protocolType = (protocolSwitch.selectedSegmentIndex == 0) ?
            .http: .https
    }
    
    @IBAction func trackEvents(_ sender: UIButton) {
        UserDefaults.standard.set(uriField.text ?? "", forKey: keyUriField);
        DispatchQueue.global(qos: .default).async {
            let url = self.parentPageViewController.getCollectorUrl()
            if url == "" {
                return
            }
            
            // Update the tracker
            let spTracker = self.tracker?.getSPTracker()
            // spTracker?.emitter.setUrlEndpoint(url)
            spTracker?.emitter.setHttpMethod(self.parentPageViewController.getMethodType())
            spTracker?.emitter.setProtocol(self.parentPageViewController.getProtocolType())
            
            // Iterate the made counter
            self.parentPageViewController.madeCounter += 28;
            
            // Track all types of events
            //DemoUtils.trackAll(self.parentPageViewController.tracker)
        }
    }
}
