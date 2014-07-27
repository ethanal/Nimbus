//
//  AppDelegate.swift
//  Nimbus
//
//  Created by Ethan Lowman on 7/25/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMetadataQueryDelegate {
    
    var statusView = StatusItemView()
    var query = NSMetadataQuery()
    var prefs = PreferencesManager()
    var api = APIClient()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        initScreenshotWatcher()
    }
    
    func initScreenshotWatcher() {
        query.delegate = self
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploadScreenshot:", name: NSMetadataQueryDidUpdateNotification, object: query)
        query.startQuery()
    }
    
    func uploadScreenshot(notification: NSNotification) {
        if prefs.uploadScreenshots == NSOffState {
            return
        }
        
        var metadataItem: NSMetadataItem? = notification.userInfo["kMDQueryUpdateAddedItems"]?.lastObject as? NSMetadataItem
        
        
        if let item = metadataItem {
            var screenshotPath: NSString = item.valueForAttribute(NSMetadataItemPathKey) as NSString
            var urlOfFile = NSURL.fileURLWithPath(screenshotPath)
            var fileData = NSFileManager.defaultManager().contentsAtPath(screenshotPath)
            uploadFile(fileData, filename: urlOfFile.lastPathComponent)
        }
    }
    
    
    func uploadFile(fileData: NSData, filename: NSString) {
        println("Attempting to upload file...")
        statusView.status = .Working
        api.addFile(fileData, filename: filename, successCallback: {(shareURL: NSURL!) -> Void in
            var pb = NSPasteboard.generalPasteboard()
            pb.clearContents()
            pb.writeObjects([shareURL.absoluteString])
            self.statusView.status = .Success
            }, errorCallback: {() -> Void in
                println("Error uploading file")
                self.statusView.status = .Error
            })
    }
    
    
    func uploadLink(link: NSURL) {
        println("Attempting to upload link...")
        statusView.status = .Working
        api.addLink(link, successCallback: {(shareURL: NSURL!) -> Void in
            var pb = NSPasteboard.generalPasteboard()
            pb.clearContents()
            pb.writeObjects([shareURL.absoluteString])
            self.statusView.status = .Success
            }, errorCallback: {() -> Void in
                println("Error uploading link")
                self.statusView.status = .Error
            })
        
    }
    

}

