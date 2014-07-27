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
        query.searchScopes = [self.screenCaptureLocation()]
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
        query.delegate = self
        query.notificationBatchingInterval = 0.1
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploadScreenshot:", name: NSMetadataQueryDidUpdateNotification, object: query)
        query.startQuery()
    }
    
    func screenCaptureLocation() -> String {
        var screenCapturePrefs: NSDictionary? = NSUserDefaults.standardUserDefaults().persistentDomainForName("com.apple.screencapture")
        
        var location: NSString? = screenCapturePrefs?.valueForKey("location")?.stringByExpandingTildeInPath as NSString?
        
        if let loc = location {
            return loc.hasSuffix("/") ? loc : (loc + "/")
        }
        
        return "~/Desktop".stringByExpandingTildeInPath + "/"
    }
    
    func uploadScreenshot(notification: NSNotification) {
        if prefs.uploadScreenshots == NSOffState {
            return
        }
        
        var metadataItem: NSMetadataItem? = notification.userInfo["kMDQueryUpdateAddedItems"]?.lastObject as? NSMetadataItem
        
        
        if metadataItem {
            var screenshotPath: NSString = metadataItem!.valueForAttribute(NSMetadataItemPathKey) as NSString
            var urlOfFile = NSURL.fileURLWithPath(screenshotPath)
            var fileData = NSFileManager.defaultManager().contentsAtPath(screenshotPath)
            uploadFile(fileData, filename: urlOfFile.lastPathComponent)
        }
    }
    
    
    func uploadFile(fileData: NSData, filename: NSString) {
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

