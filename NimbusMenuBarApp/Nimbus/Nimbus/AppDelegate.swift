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
    
    override init() {
        super.init()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        sw = ScreenshotWatcher(uploadFileCallback: uploadFile);
        sw!.startWatchingPath(screenCaptureLocation())
    }
    
    func screenCaptureLocation() -> String {
        let screenCapturePrefs: NSDictionary? = NSUserDefaults.standardUserDefaults().persistentDomainForName("com.apple.screencapture")
        
        let location: String? = screenCapturePrefs?.valueForKey("location")?.stringByExpandingTildeInPath as String?
        
        if let loc = location {
            return loc.hasSuffix("/") ? loc : (loc + "/")
        }
        
        return ("~/Desktop" as NSString).stringByExpandingTildeInPath + "/"
    }
    
    func uploadFile(fileData: NSData!, filename: String!) {
        print(filename, terminator: "");
//        NSMetadataItem *metadata = NSMetadataItem(URL: filename)
//        BOOL isScreenshot = [[metadata valueForAttribute:@"kMDItemIsScreenCapture"] integerValue] == 1;
        statusView.status = .Working
        api.addFile(fileData, filename: filename, successCallback: {(shareURL: NSURL!) -> Void in
            let pb = NSPasteboard.generalPasteboard()
            pb.clearContents()
            pb.writeObjects([shareURL.absoluteString])
            self.statusView.status = .Success
            }, errorCallback: {() -> Void in
                print("Error uploading file")
                self.statusView.status = .Error
            })
    }
    
    func uploadLink(link: NSURL) {
        statusView.status = .Working
        api.addLink(link, successCallback: {(shareURL: NSURL!) -> Void in
            let pb = NSPasteboard.generalPasteboard()
            pb.clearContents()
            pb.writeObjects([shareURL.absoluteString])
            self.statusView.status = .Success
            }, errorCallback: {() -> Void in
                print("Error uploading link")
                self.statusView.status = .Error
            })
        
    }
}
