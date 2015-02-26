
//
//  APIClient.swift
//  Nimbus
//
//  Created by Ethan Lowman on 7/25/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

import Cocoa

class APIClient: NSObject {
    var prefs = PreferencesManager()
    
    var apiRoot: String {
    get {
        return "http://api." + prefs.hostname
    }
    }
    
    var authToken: String
    
    override init() {
        if let token = KeychainService.loadToken() {
            authToken = token
        } else {
            authToken = ""
        }
        
        super.init()
    }
    
    
    func request(uri: NSString, withAuth: Bool) -> NSMutableURLRequest {
        let r = NSMutableURLRequest(URL: NSURL(string: apiRoot + uri)!)
        if withAuth {
            r.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")
        }
        r.timeoutInterval = 10.0
        return r
    }
    
    
    func getTokenForUsername(username: NSString, password: NSString, successCallback: ((NSString!) -> Void)?, errorCallback: (() -> Void)?) {
        let req = request("/api-token-auth", withAuth: false)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.HTTPMethod = "POST"
        
        let requestJSON = JSON([
            "username": username,
            "password": password
            ])
        
        req.HTTPBody = requestJSON.rawString()!.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            var responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            if (error != nil) {
                print(responseString)
                if (errorCallback != nil) {
                    errorCallback!()
                }
                return
            }

            var responseJSON = JSON(data: data!)
            
            if let token = responseJSON["token"].string {
                if (successCallback != nil) {
                    self.authToken = token
                    successCallback!(token)

                }
            } else  {
                println(responseString)
                if (errorCallback != nil) {
                    errorCallback!()
                }
                return
            }
        
        }
    }
    
    
    func addFile(fileData: NSData, filename: NSString, successCallback: ((NSURL!) -> Void)?, errorCallback: (() -> Void)?) {
        let req = request("/media/add_file", withAuth: true)
        req.HTTPMethod = "POST"
        
        var boundary = "gc0p4Jq0M2Yt08jU534c0pgc0p4Jq0M2Yt08jU534c0p"
        var contentType = "multipart/form-data; boundary=\(boundary)"
        req.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var postData = NSMutableData()
        postData.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postData.appendData(NSData(data: fileData))
        postData.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        req.HTTPBody = postData
        
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            var responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            if (error != nil) {
                println(responseString)
                if (errorCallback != nil) {
                    errorCallback!()
                }
                return
            }
            
            var responseJSON = JSON(data)
            
            if let shareURL = responseJSON["share_url"].URL {
                if (successCallback != nil) {
                    successCallback!(shareURL)
                }
            } else  {
                println(responseString)
                if (errorCallback != nil) {
                    errorCallback!()
                }
                return
            }

        }
    }
    
    func addLink(link: NSURL, successCallback: ((NSURL!) -> Void)?, errorCallback: (() -> Void)?) {
        let req = request("/media/add_link", withAuth: true)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.HTTPMethod = "POST"
        
        let requestJSON = JSON([
            "target_url": link.absoluteString!
            ])
        
        req.HTTPBody = requestJSON.rawString()!.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            var responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            if (error != nil) {
                println(responseString)
                if (errorCallback != nil) {
                    errorCallback!()
                }
                return
            }
            
            var responseJSON = JSON(data)
            
            
            if let shareURL = responseJSON["share_url"].URL {
                if (successCallback != nil) {
                    successCallback!(shareURL)
                }
            } else  {
                println(responseString)
                if (errorCallback != nil) {
                    errorCallback!()
                }
                return
            }

            
        }
    }

}
