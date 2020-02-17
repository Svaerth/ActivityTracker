//
//  Session.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/12/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Foundation
import AppKit

struct Session : Codable{
    
    let FILENAME_EXTENSION = "ats"
    let date:Date;
    var activityPhases:[ActivityPhase]
    
    init () {
        self.date = Date()
        self.activityPhases = []
    }
    
    init(date:Date,activityPhases:[ActivityPhase]){
        self.date = date
        self.activityPhases = activityPhases
    }
    
    func saveToDisk(){
        do{
            //creating JSON object from session
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try encoder.encode(self)
            let jsonString = String(data:json, encoding: .utf8)
            if (jsonString == nil){
                let errorMsg = "Failed to parse json data to string"
                throw NSError(domain: "JSONDataParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey:errorMsg])
            }
            
            let directory = (UserPreferences.GetSessionStorageDirectory() as NSString).expandingTildeInPath
            
            //creating the folder hierarchy to save the file at if it doesn't
            //exist already
            if !FileManager.default.fileExists(atPath: directory) {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            }
            
            //saving to disk
            let filename = "\(directory)/\(date).\(FILENAME_EXTENSION)"
            try jsonString?.write(toFile:filename, atomically:true, encoding: .unicode)
            
        }catch{
            let alert = NSAlert(error:error)
            alert.runModal()
        }
    }
    
}
