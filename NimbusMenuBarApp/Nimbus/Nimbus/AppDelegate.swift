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
    var prefs = PreferencesManager()
    var api = APIClient()
    var sw: ScreenshotWatcher?
    
    init() {
        super.init()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        sw = ScreenshotWatcher(uploadFileCallback: uploadFile);
        sw!.startWatchingPath(screenCaptureLocation())
    }
    
    func screenCaptureLocation() -> String {
        var screenCapturePrefs: NSDictionary? = NSUserDefaults.standardUserDefaults().persistentDomainForName("com.apple.screencapture")
        
        var location: NSString? = screenCapturePrefs?.valueForKey("location")?.stringByExpandingTildeInPath as NSString?
        
        if let loc = location {
            return loc.hasSuffix("/") ? loc : (loc + "/")
        }
        
        return "~/Desktop".stringByExpandingTildeInPath + "/"
    }
    
    func uploadFile(fileData: NSData!, filename: String!) {
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
