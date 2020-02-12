//
//  AppDelegate.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/8/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Cocoa
import SwiftUI
import Foundation
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserPreferences.RegisterDefaultPreferences()
    }
    
}

