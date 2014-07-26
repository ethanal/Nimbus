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
    @IBOutlet var usernameLabel: NSTextField
    @IBOutlet var passwordLabel: NSTextField
    
    override func windowDidLoad() {
        super.windowDidLoad()
        websiteHostnameField.stringValue = prefs.hostname
        usernameField.stringValue = prefs.username
        uploadScreenshotsCheckbox.state = prefs.uploadScreenshots
        updateAccountUI()
    }
    

    @IBAction func accountActionButtonPressed(sender: AnyObject) {
        prefs.loggedIn = !prefs.loggedIn
        updateAccountUI()
    }
    
    func updateAccountUI() {
        if prefs.loggedIn {
            accountActionButton.title = "Login"
            passwordField.hidden = false
            passwordLabel.hidden = false
            usernameField.hidden = false
            usernameLabel.hidden = true
            KeychainManager.saveToken("-")
            
        } else {
            accountActionButton.title = "Logout"
            passwordField.hidden = true
            passwordLabel.hidden = true
            usernameField.hidden = true
            usernameLabel.hidden = false
            usernameLabel.stringValue = usernameField.stringValue
            passwordField.stringValue = ""
            KeychainManager.saveToken("12345")
        }
    }
    
    // NSWindowDelegate
    func windowWillClose(notification: NSNotification!) {
        prefs.hostname = websiteHostnameField.stringValue
        prefs.username = usernameField.stringValue
        prefs.uploadScreenshots = uploadScreenshotsCheckbox.state
    }
    
    
    
}
