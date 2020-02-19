//
//  ActivityPhase.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/12/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Foundation

struct ActivityPhase : Codable, CustomStringConvertible{
    
    //overrides how this object will be converted to a string
    var description: String {
        get {
            return "start: \(startTime) end: \(endTime) type: \(activityType) allowedDist: \(allowedActivityDistance)"
        }
    }
    
    let startTime : Date
    let endTime : Date
    let activityType : ActivityType
    //the amount of time allowed between inputs for them to still be considered
    //part of the same phase of activity
    let allowedActivityDistance : Int
    //the amount of inactivity you can have before getting scolded
    let allowedInactivity : Int
    
    init(startTime: Date, endTime: Date, activityType: ActivityType){
        self.startTime = startTime
        self.endTime = endTime
        self.activityType = activityType
        allowedActivityDistance = UserPreferences.GetAllowedActivityDistance()
        allowedInactivity = UserPreferences.GetAllowedInactivity()
    }
    
}
