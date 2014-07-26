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
    var apiRoot: String
    @lazy var authToken: String = {
        return "---"
    }()
    
    init() {
        apiRoot = "http://api." + prefs.hostname
    }
    
    func request(uri: NSString) -> NSMutableURLRequest {
        let r = NSMutableURLRequest(URL: NSURL(string: apiRoot + uri))
        r.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        r.timeoutInterval = 10.0
        return r
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
        let req = request("/api-token-auth")
        req.HTTPMethod = "POST"
        
        let jsonString = JSONStringify([
            "username": username,
            "password": password
            ])
        
        req.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            println(JSONValue(data))
            if error {
                println(response)
                println(data)
                println(error)
                
                if let cb = errorCallback {
                    cb()
                }
            }
            
            var json = JSONValue(data)["token"]
            
            if let token = json.string {
                if let cb = successCallback {
//                    self.authToken = token
                    cb(token)

                }
            } else  {
                if let cb = errorCallback {
                    cb()
                }
            }
            
        }
    }
}
