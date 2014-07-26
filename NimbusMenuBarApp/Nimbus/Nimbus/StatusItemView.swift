//
//  StatusItemView.swift
//  Nimbus
//
//  Created by Ethan Lowman on 7/25/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

import Cocoa

enum StatusItemViewStatus: String {
    case Normal = "Normal"
    case Error = "Error"
    case Success = "Success"
    case Working = "Working"
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

class StatusItemView: NSView, NSMenuDelegate, NSWindowDelegate {
    let statusItemWidth = 30.0
    let statusBarHeight = NSStatusBar.systemStatusBar().thickness
    let statusItemRect: NSRect
    
    var status: StatusItemViewStatus {
    didSet {
        println(status.toRaw())
        switch status {
        case .Normal:
            break
        case .Working:
            break
        default:
            var statusAtDispatch = status
            delay(2.0) {
                if statusAtDispatch == self.status {
                    self.status = .Normal
                    self.updateUI()
                }
            }
        }
        self.updateUI()
    }
    }
    
    var active: Bool {
    didSet {
        self.updateUI()
    }
    }
    
    var progressIndex: Int
    
    
    var statusItem: NSStatusItem
    var popover: NSPopover?
    var preferencesWindowController: NSWindowController?
    
    var prefs = PreferencesManager()
    
    @lazy var imageView: NSImageView = {
        let view = NSImageView(frame: self.statusItemRect)
        return view
        }()
    
    @lazy var statusItemMenu: NSMenu = {
        let menu: NSMenu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = true
        menu.addItem(self.websiteItem)
        menu.addItem(self.preferencesItem)
        menu.addItem(self.quitItem)
        return menu
        }()
    
    @lazy var websiteItem: NSMenuItem = {
        let item = NSMenuItem(title: "Launch Nimbus Website", action: "openWebsite:", keyEquivalent: "")
        item.target = self
        return item
        }()
    
    @lazy var preferencesItem: NSMenuItem = {
        let item = NSMenuItem(title: "Preferences", action: "openPreferences:", keyEquivalent: "")
        item.target = self
        return item
        }()
    
    @lazy var quitItem: NSMenuItem = {
        let item = NSMenuItem(title: "Quit", action: "quitApp:", keyEquivalent: "")
        item.target = self
        return item
        }()
    
    
    
    init() {
        statusItemRect = NSMakeRect(0, 0, statusItemWidth, statusBarHeight)
        active = false
        status = .Normal
        progressIndex = 0
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(statusItemWidth)
        
        super.init(frame: statusItemRect)
        
        statusItem.view = self
        statusItem.menu = statusItemMenu
        self.addSubview(imageView)
        
        updateUI()
    }

    override func drawRect(dirtyRect: NSRect) {
        if active {
            NSColor.selectedMenuItemColor().setFill()
            NSRectFill(dirtyRect)
        } else {
            NSColor.clearColor().setFill()
            NSRectFill(dirtyRect)
        }
    }
    
    func updateUI() {
        if status != .Working {
            var imageNames: Dictionary<StatusItemViewStatus, String> = [
                .Normal: "menubar",
                .Error: "menubar-error",
                .Success: "menubar-success",
            ]
            self.imageView.image = NSImage(named: active ? "menubar-highlighted" : imageNames[status])
            self.needsDisplay = true
        } else {
            
        }
        
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        active = true
        statusItem.popUpStatusItemMenu(statusItemMenu)
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        active = false
    }
    
    func openWebsite(sender: NSStatusItem!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://account." + prefs.hostname))
    }
    
    func openPreferences(sender: NSStatusItem!) {
        if !preferencesWindowController {
            preferencesWindowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        }
        preferencesWindowController!.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func quitApp(sender: NSStatusItem!) {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // NSMenuDelegate
    func menuDidClose(menu: NSMenu!) {
        active = false
    }
}
