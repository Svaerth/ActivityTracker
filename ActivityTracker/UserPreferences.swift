//
//  UserPreferences.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/11/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Foundation

class UserPreferences{
    
    private static let allowedInactivityKey = "AllOWED_INACTIVITY"
    private static let allowedInactivityDefault:Int = 20
    
    class func RegisterDefaultPreferences(){
        
        //UserDefaults.standard.removeObject(forKey: allowedInactivityKey)
        
        let prefsDict = [
            allowedInactivityKey : NSNumber(value: allowedInactivityDefault)
        ]
        
        UserDefaults.standard.register(defaults: prefsDict)
        
    }
    
    class func SetAllowedInactivity(_ newValue: Int){
        UserDefaults.standard.set(newValue, forKey: allowedInactivityKey)
    }
    
    class func GetAllowedInactivity() -> Int{
        return UserDefaults.standard.integer(forKey: allowedInactivityKey)
    }
    
}
