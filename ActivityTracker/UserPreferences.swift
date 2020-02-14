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
    private static let allowedInactivityDefault:Int = 120
    
    private static let allowedActivityDistanceKey = "AllOWED_ACTIVITY_DISTANCE"
    private static let allowedActivityDistanceDefault:Int = 5
    
    class func RegisterDefaultPreferences(){
        
        //UserDefaults.standard.removeObject(forKey: allowedInactivityKey)
        
        let prefsDict = [
            allowedInactivityKey : NSNumber(value: allowedInactivityDefault),
            allowedActivityDistanceKey : NSNumber(value: allowedActivityDistanceDefault)
        ]
        
        UserDefaults.standard.register(defaults: prefsDict)
        
    }
    
    class func SetAllowedInactivity(_ newValue: Int){
        UserDefaults.standard.set(newValue, forKey: allowedInactivityKey)
    }
    
    class func GetAllowedInactivity() -> Int{
        return UserDefaults.standard.integer(forKey: allowedInactivityKey)
    }
    
    class func SetAllowedActivityDistance(_ newValue: Int){
        UserDefaults.standard.set(newValue, forKey: allowedActivityDistanceKey)
    }
    
    class func GetAllowedActivityDistance() -> Int{
        return UserDefaults.standard.integer(forKey: allowedActivityDistanceKey)
    }
    
}
