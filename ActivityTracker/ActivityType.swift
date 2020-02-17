//
//  ActivityType.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/13/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Foundation

enum ActivityType : String , Codable{
    case active = "active"
    case inactive = "inactive"
    case paused = "paused"
    case screenLocked = "screenLocked"
    case scolded = "scolded"
}
