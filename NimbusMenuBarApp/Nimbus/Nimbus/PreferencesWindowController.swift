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
    
    @IBOutlet weak var hostnameField: NSTextField?
    @IBOutlet weak var usernameField: NSTextField?
    @IBOutlet weak var passwordField: NSSecureTextField?
    @IBOutlet weak var uploadScreenshotsCheckbox: NSButton?
    @IBOutlet weak var accountActionButton: NSButton?
    @IBOutlet weak var hostnameLabel: NSTextField?
    @IBOutlet weak var usernameLabel: NSTextField?
    @IBOutlet weak var passwordLabel: NSTextField?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        updateAccountUI()
    }
    
    @IBAction func uploadScreenshotsCheckboxPressed(sender: AnyObject) {
        prefs.uploadScreenshots = uploadScreenshotsCheckbox!.state
    }

    @IBAction func accountActionButtonPressed(sender: AnyObject) {
        KeychainManager.loadUsername()
        if !prefs.loggedIn {
            prefs.hostname = hostnameField!.stringValue
            
            api.getTokenForUsername(usernameField!.stringValue, password: passwordField!.stringValue, successCallback: {(token: NSString!) -> Void in
                self.prefs.loggedIn = true
                KeychainManager.saveToken(token, username: self.usernameField!.stringValue)

                self.updateAccountUI()
                }, errorCallback: {() -> Void in
                    var alert = NSAlert()
                    alert.messageText = "Unable to login with provided credentials"
                    alert.runModal()
                })
            
            
        } else {
            prefs.loggedIn = false
            updateAccountUI()
        }
        
        
    }
    
    func updateAccountUI() {
        uploadScreenshotsCheckbox!.state = prefs.uploadScreenshots

        if prefs.loggedIn {
            accountActionButton!.title = "Logout"
            
            hostnameField!.hidden = true
            hostnameLabel!.hidden = false
            hostnameLabel!.stringValue = prefs.hostname
            
            usernameField!.hidden = true
            usernameLabel!.hidden = false
            if let u = KeychainManager.loadUsername() {
                usernameLabel!.stringValue = u
            } else {
                usernameLabel!.stringValue = ""
            }
            
            passwordField!.hidden = true
            passwordLabel!.hidden = true
            
        } else {
            accountActionButton!.title = "Login"
            
            hostnameField!.hidden = false
            hostnameField!.stringValue = ""
            hostnameLabel!.hidden = true
            
            usernameField!.hidden = false
            usernameField!.stringValue = ""
            usernameLabel!.hidden = true
            
            passwordField!.hidden = false
            passwordField!.stringValue = ""
            passwordLabel!.hidden = false
        }
    }
    
    
    
}
