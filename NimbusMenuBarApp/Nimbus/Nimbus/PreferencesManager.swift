//
//  PreferencesManager.swift
//  Nimbus
//
//  Created by Ethan Lowman on 7/25/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

import Cocoa

class PreferencesManager: NSObject {
    var prefs = NSUserDefaults.standardUserDefaults()
    
    var hostname: String {
        get {
            if let val = prefs.stringForKey("hostname") as String! {
                return val
            }
            return "example.com"
        }
        set {
            prefs.setObject(newValue, forKey: "hostname")
        }
    }
    
    var loggedIn: Bool {
        get {
            if let val = prefs.boolForKey("loggedIn") as Bool! {
                return val
            }
            return false
        }
        set {
            prefs.setBool(newValue, forKey: "loggedIn")
        }
    }
    
    var username: String {
        get {
            if let val = prefs.stringForKey("username") as String! {
                return val
            }
            return ""
        }
        set {
            prefs.setValue(newValue, forKey: "username")
        }
    }
    
    
    var uploadScreenshots: Int {
        get {
            if let val = prefs.integerForKey("uploadScreenshots") as Int! {
                return val
            }
            return 1
        }
        set {
            prefs.setInteger(newValue, forKey: "uploadScreenshots")
        }
    }
    
}
