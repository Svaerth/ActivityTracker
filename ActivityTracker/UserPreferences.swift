//
//  UserPreferences.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/11/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Foundation

class UserPreferences{
    
    class func RegisterDefaultPreferences(){
        
        //UserDefaults.standard.removeObject(forKey: allowedInactivityKey)
        
        let prefsDict:[String : Any] = [
            allowedInactivityKey : NSNumber(value: allowedInactivityDefault),
            allowedActivityDistanceKey : NSNumber(value: allowedActivityDistanceDefault),
            sessionStorageDirectoryKey : sessionStorageDirectoryDefault
            ]
        
        UserDefaults.standard.register(defaults: prefsDict)
        
    }
    
    
    //MARK: allowed inactivity
    private static let allowedInactivityKey = "AllOWED_INACTIVITY"
    private static let allowedInactivityDefault:Int = 120
    
    class func SetAllowedInactivity(_ newValue: Int){
        UserDefaults.standard.set(newValue, forKey: allowedInactivityKey)
    }
    
    class func GetAllowedInactivity() -> Int{
        return UserDefaults.standard.integer(forKey: allowedInactivityKey)
    }
    
    //MARK: allowed activity distance
    private static let allowedActivityDistanceKey = "AllOWED_ACTIVITY_DISTANCE"
    private static let allowedActivityDistanceDefault:Int = 5
    
    class func SetAllowedActivityDistance(_ newValue: Int){
        UserDefaults.standard.set(newValue, forKey: allowedActivityDistanceKey)
    }
    
    class func GetAllowedActivityDistance() -> Int{
        return UserDefaults.standard.integer(forKey: allowedActivityDistanceKey)
    }
    
    //MARK: session storage directory
    private static let sessionStorageDirectoryKey = "SESSION_STORAGE_DIRECTORY"
    private static let sessionStorageDirectoryDefault:String = "~/Documents/Activity Tracker Sessions"
    
    class func SetSessionStorageDirectory(_ newValue: String){
        UserDefaults.standard.set(newValue, forKey: sessionStorageDirectoryKey)
    }
    
    class func GetSessionStorageDirectory() -> String{
        return UserDefaults.standard.string(forKey: sessionStorageDirectoryKey) ?? sessionStorageDirectoryDefault
    }
    
}
