//
//  StatusItemView.swift
//  Nimbus
//
//  Created by Ethan Lowman on 7/25/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

import Cocoa


class StatusItemView: NSView, NSMenuDelegate, NSWindowDelegate {
    let statusItemWidth = 30.0
    let statusBarHeight = NSStatusBar.systemStatusBar().thickness
    let statusItemRect: NSRect
    
    var active: Bool {
        didSet {
            self.updateUI()
        }
    }
    
    
    var statusItem: NSStatusItem
    var popover: NSPopover?
    var preferencesWindowController: NSWindowController?
    
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
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(statusItemWidth)
        
        super.init(frame: statusItemRect)
        
        statusItem.view = self
        statusItem.menu = statusItemMenu
        self.addSubview(imageView)
        
        updateUI()
    }

    override func drawRect(dirtyRect: NSRect) {
        if self.active {
            NSColor.selectedMenuItemColor().setFill()
            NSRectFill(dirtyRect)
        } else {
            NSColor.clearColor().setFill()
            NSRectFill(dirtyRect)
        }
    }
    
    func updateUI() {
        self.imageView.image = NSImage(named: self.active ? "menubar-highlighted" : "menubar")
        self.needsDisplay = true
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        active = true
        statusItem.popUpStatusItemMenu(statusItemMenu)
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        active = false
    }
    
    func openWebsite(sender: NSStatusItem!) {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    func openPreferences(sender: NSStatusItem!) {
        if !preferencesWindowController {
            preferencesWindowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        }
        preferencesWindowController!.showWindow(self)
    }
    
    func quitApp(sender: NSStatusItem!) {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // NSMenuDelegate
    func menuDidClose(menu: NSMenu!) {
        self.active = false
    }
}
