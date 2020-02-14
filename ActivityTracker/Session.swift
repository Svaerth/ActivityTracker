//
//  Session.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/12/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Foundation

class Session {
    
    let date:Date;
    var activityPhases:[ActivityPhase]
    
    init(date:Date,activityPhases:[ActivityPhase]){
        self.date = date
        self.activityPhases = activityPhases
    }
    
}
