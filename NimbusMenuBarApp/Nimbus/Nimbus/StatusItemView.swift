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
    
    var status: StatusItemViewStatus = .Normal {
    didSet {
        switch status {
        case .Normal:
            progressFrame = 0
        case .Working:
            if oldValue != .Working {
                progressFrame = 1
            }
        default:
            progressFrame = 0
            
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
    
    var active: Bool = false {
    didSet {
        self.updateUI()
    }
    }
    
    var progressFrame: Int = 0 {
    didSet {
        if self.progressFrame != 0 {
            delay(0.25) {
                if self.progressFrame != 0 {
                    self.progressFrame = 1 + (self.progressFrame % 3)
                }
            }
        }

        updateUI()
    }
    }
    
    
    var statusItem: NSStatusItem
    var popover: NSPopover?
    var preferencesWindowController: NSWindowController?
    
    var prefs = PreferencesManager()
    
    lazy var imageView: NSImageView = {
        let view:NSImageView = NSImageView(frame: self.statusItemRect)
        view.unregisterDraggedTypes()
        return view
        }()
    
    lazy var statusItemMenu: NSMenu = {
        let menu: NSMenu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = true
        menu.addItem(self.websiteItem)
        menu.addItem(self.preferencesItem)
        menu.addItem(self.quitItem)
        return menu
        }()
    
    lazy var websiteItem: NSMenuItem = {
        let item = NSMenuItem(title: "Launch Nimbus Website", action: "openWebsite:", keyEquivalent: "")
        item.target = self
        return item
        }()
    
    lazy var preferencesItem: NSMenuItem = {
        let item = NSMenuItem(title: "Preferences", action: "openPreferences:", keyEquivalent: "")
        item.target = self
        return item
        }()
    
    lazy var quitItem: NSMenuItem = {
        let item = NSMenuItem(title: "Quit", action: "quitApp:", keyEquivalent: "")
        item.target = self
        return item
        }()
    
    
    
    init() {
        statusItemRect = NSMakeRect(0, 0, CGFloat(statusItemWidth), CGFloat(statusBarHeight))
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(statusItemWidth))
        
        super.init(frame: statusItemRect)
        
        statusItem.view = self
        statusItem.menu = statusItemMenu
        self.addSubview(imageView)
        
        self.registerForDraggedTypes([NSFilenamesPboardType, NSURLPboardType, NSStringPboardType])
        
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
        if (active) {
            self.imageView.image = NSImage(named: "menubar-highlighted")
        } else {
            if status != .Working {
                var imageNames: Dictionary<StatusItemViewStatus, String> = [
                    .Normal: "menubar",
                    .Error: "menubar-error",
                    .Success: "menubar-success",
                ]
                self.imageView.image = NSImage(named: imageNames[status])
            } else {
                self.imageView.image = NSImage(named: "menubar-progress-\(progressFrame)")
            }
        }
        
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
    
    override func draggingEntered(sender: NSDraggingInfo!) -> NSDragOperation {
        return .Copy
    }
    
    override func draggingEnded(sender: NSDraggingInfo!) {
        if NSPointInRect(sender.draggingLocation(), self.frame) {
            handleDrop(sender)
        }
    }
    
    // Manually called instead of performDragOperation
    // http://openradar.appspot.com/radar?id=1745403
    func handleDrop(sender: NSDraggingInfo!) -> Bool {
        var pboard = sender.draggingPasteboard();
        var types = (pboard.types as NSArray)
        var appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        var fileManager = NSFileManager.defaultManager()
        
        if types.containsObject(NSFilenamesPboardType) {
            var fileURL = NSURL.URLFromPasteboard(pboard)
            var fileData = fileManager.contentsAtPath(fileURL.path)
            var fileName = fileURL.lastPathComponent
            
            if (fileData != nil) && (fileName != nil) {
                appDelegate.uploadFile(fileData!, filename: fileName!)
            } else {
                status = .Error
            }
            
        } else if types.containsObject(NSURLPboardType) {
            var url = NSURL.URLFromPasteboard(pboard)
            appDelegate.uploadLink(url)
            
        } else if types.containsObject(NSStringPboardType) {
            var text = pboard.stringForType(NSStringPboardType) as NSString
            
            var legalChars = NSMutableCharacterSet.alphanumericCharacterSet()
            legalChars.formUnionWithCharacterSet(NSCharacterSet.whitespaceCharacterSet())
            legalChars.invert()
            var filename = (text.componentsSeparatedByCharactersInSet(legalChars) as NSArray).componentsJoinedByString("") as NSString
            filename = filename.substringToIndex(30 > text.length ? text.length : 30) + ".txt"
            
            var fileData = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            
            if (fileData != nil) && (filename != nil) {
                appDelegate.uploadFile(fileData, filename: filename)
            } else {
                status = .Error
            }
        }
        
        return true;
    }
    
}
