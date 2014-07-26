//
//  PreferencesWindowController.swift
//  Nimbus
//
//  Created by Ethan Lowman on 7/25/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    var prefs = PreferencesManager()
    var api = APIClient()
    
    @IBOutlet weak var websiteHostnameField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var uploadScreenshotsCheckbox: NSButton!
    @IBOutlet weak var accountActionButton: NSButton!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        websiteHostnameField.stringValue = prefs.hostname
        usernameField.stringValue = prefs.username
        uploadScreenshotsCheckbox.state = prefs.uploadScreenshots
        
    }
    

    @IBAction func accountActionButtonPressed(sender: AnyObject) {
        if prefs.loggedIn {
            accountActionButton.title = "Login"
            passwordField.enabled = true
            KeychainManager.saveToken("-")
            prefs.loggedIn = false
        } else {
            accountActionButton.title = "Logout"
            passwordField.enabled = false
            KeychainManager.saveToken("12345")
            prefs.loggedIn = true
        }
    }
    
    // NSWindowDelegate
    func windowWillClose(notification: NSNotification!) {
        prefs.hostname = websiteHostnameField.stringValue
        prefs.username = usernameField.stringValue
        prefs.uploadScreenshots = uploadScreenshotsCheckbox.state
    }
    
    
    
}
