// Modified from http://matthewpalmer.net/blog/2014/06/21/example-ios-keychain-swift-save-query/

import Cocoa
import Security

let serviceIdentifier = "Nimbus"
let accessGroup = "Nimbus"

class KeychainManager: NSObject {
    
    class func saveToken(token: NSString, username: NSString) {
        self.save(serviceIdentifier, username: username, token: token)
    }
    
    class func loadUsername() -> NSString? {
        var username = self.getUsername(serviceIdentifier)
        return username
    }
    
    class func loadToken() -> NSString? {
        var token = self.getToken(serviceIdentifier)
        
        return token
    }
    
    class func save(service: NSString, username: NSString, token: NSString) {
        var dataFromString: NSData = token.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        // Instantiate a new default keychain query
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, username, dataFromString], forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecValueData])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionaryRef)
        
        // Add the new keychain item
        var status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
    }
    
    class func getToken(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, kCFBooleanTrue, kSecMatchLimitOne], forKeys: [kSecClass, kSecAttrService, kSecReturnData, kSecMatchLimit])
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        let opaque = dataTypeRef?.toOpaque()
        
        var contentsOfKeychain: NSString?
        
        if let op = opaque? {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            
            // Convert the data retrieved from the keychain into a string
            contentsOfKeychain = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
        } else {
            println("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
    
    class func getUsername(service: NSString) -> NSString? {
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, kCFBooleanTrue, kSecMatchLimitOne], forKeys: [kSecClass, kSecAttrService, kSecReturnAttributes, kSecMatchLimit])
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        let opaque = dataTypeRef?.toOpaque()
        
        var contentsOfKeychain: NSDictionary?
        
        if let op = opaque? {
            let data = Unmanaged<NSDictionary>.fromOpaque(op).takeUnretainedValue()
            if data != nil {
                return data.objectForKey(kSecAttrAccount) as? NSString
            }
            
        } else {
            println("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return nil
    }
}