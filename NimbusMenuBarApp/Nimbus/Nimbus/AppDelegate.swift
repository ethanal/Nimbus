//
//  AppDelegate.swift
//  Nimbus
//
//  Created by Ethan Lowman on 7/25/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMetadataQueryDelegate {
    
    var statusView: StatusItemView?
    var query: NSMetadataQuery?
    var prefs = PreferencesManager()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        statusView = StatusItemView()
        initScreenshotWatcher()
    }
    
    func initScreenshotWatcher() {
        query = NSMetadataQuery()
        query!.delegate = self
        query!.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "change:", name: NSMetadataQueryDidUpdateNotification, object: query)
        query!.startQuery()
    }
    
    func change(notification: NSNotification) {
        if prefs.uploadScreenshots == NSOffState {
            return
        }
        
        var metadataItem: NSMetadataItem? = notification.userInfo["kMDQueryUpdateAddedItems"]?.lastObject as? NSMetadataItem
        
        
        if let item = metadataItem {
            var screenshotPath: NSString = item.valueForAttribute(NSMetadataItemPathKey) as NSString
            var urlOfFile = NSURL.fileURLWithPath(screenshotPath)
            
            var pb = NSPasteboard.generalPasteboard()
            pb.clearContents()
            pb.writeObjects([urlOfFile.lastPathComponent])
            println(urlOfFile.lastPathComponent)
        }
    }
    
    

}

