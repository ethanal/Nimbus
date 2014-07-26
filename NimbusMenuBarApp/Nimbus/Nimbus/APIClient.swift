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
    
    var authToken: String?
    
    
    func request(uri: NSString, withAuth: Bool) -> NSMutableURLRequest {
        let r = NSMutableURLRequest(URL: NSURL(string: apiRoot + uri))
        r.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if withAuth {
            var token = ""
            if let t = authToken {
                token = t
            }
            r.setValue("Token " + token, forHTTPHeaderField: "Authorization")
        }
        r.timeoutInterval = 10.0
        return r
    }
    
    func request(uri:NSString) -> NSMutableURLRequest {
        return request(uri, withAuth: false)
    }
    
    func JSONStringify(jsonObj: AnyObject) -> String {
        var e: NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(
            jsonObj,
            options: NSJSONWritingOptions(0),
            error: &e)
        if e {
            return ""
        } else {
            return NSString(data: jsonData, encoding: NSUTF8StringEncoding)
        }
    }
    
    func getTokenForUsername(username: NSString, password: NSString, successCallback: ((NSString!) -> Void)?, errorCallback: (() -> Void)?) {
        let req = request("/api-token-auth", withAuth: false)
        req.HTTPMethod = "POST"
        
        let requestJSON = JSONValue([
            "username": username,
            "password": password
            ])
        
        req.HTTPBody = requestJSON.rawJSONString.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            var responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            if error {
                print(responseString)
                if let cb = errorCallback {
                    cb()
                }
                return
            }
            
            var responseJSON = JSONValue(data)
            
            if let token = responseJSON["token"].string {
                if let cb = successCallback {
                    self.authToken = token
                    cb(token)

                }
            } else  {
                if let cb = errorCallback {
                    cb()
                }
                return
            }
        
        }
    }
}
