//
//  ViewController.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/11/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Cocoa
import AppKit

class MainWindow : NSViewController {
    
    
    
    let EVENTS_TO_MONITOR:NSEvent.EventTypeMask = [.keyDown,.mouseMoved,.scrollWheel,.leftMouseDown,.rightMouseDown,.otherMouseDown,.leftMouseDragged,.rightMouseDragged]
    let ALLOWED_INACTIVITY_LABEL_TEXT = "How long to wait before showing reminder? (Seconds)"
    
    var lastActivity:Date = Date()
    var beginningActivity:Date = Date()
    
    var screenIsLocked = false
    var paused = false
    
    //event variables
    var inputOccurred = false
    
    @IBOutlet weak var PauseBtn: NSButton!
    @IBOutlet weak var allowedInactivityTxtField: NSTextField!
    @IBOutlet weak var allowedInactivityLabel: NSTextField!
    
    override func viewDidLoad() {
        
        //setting up update timer
        _ = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(timerWentOff), userInfo: nil, repeats: true)
        
        SetupEventMonitoring()
    }
    
    override func viewWillAppear() {
        allowedInactivityTxtField.stringValue = "\(UserPreferences.GetAllowedInactivity())"
        allowedInactivityLabel.stringValue = ALLOWED_INACTIVITY_LABEL_TEXT
    }
    
    func update(){
        
        if (screenIsLocked == false && paused == false){
            
            var lastActivityShouldUpdate = false
            
            if inputOccurred{
                lastActivityShouldUpdate = true
            }
            
            //showing reminder popup if you've been inactive too long
            if (Date().timeIntervalSince(lastActivity) > TimeInterval(UserPreferences.GetAllowedInactivity())){
                NSApplication.shared.activate(ignoringOtherApps: true)
                let reminder = NSAlert()
                reminder.alertStyle = .informational
                reminder.messageText = "Back To Work!"
                reminder.addButton(withTitle: "Dismiss")
                reminder.runModal()
                self.lastActivity = Date()
            }
            
            inputOccurred = false
            
            if lastActivityShouldUpdate{
                lastActivity = Date()
            }
            
        }
        
    }
    
    func SetupEventMonitoring(){
        
        //input events
        NSEvent.addGlobalMonitorForEvents(matching: EVENTS_TO_MONITOR) { (event) in
            self.inputOccurred = true
        }
        
        NSEvent.addLocalMonitorForEvents(matching: EVENTS_TO_MONITOR) { (event) in
            self.inputOccurred = true
            return event
        }
        
        //screen lock/unlock events
        let center = DistributedNotificationCenter.default()
        center.addObserver(self, selector: #selector(ScreenLocked), name: NSNotification.Name(rawValue: "com.apple.screenIsLocked"), object: nil)
        center.addObserver(self, selector: #selector(ScreenUnlocked), name: NSNotification.Name(rawValue: "com.apple.screenIsUnlocked"), object: nil)
        
    }
    
    @objc func ScreenLocked(){
        screenIsLocked = true
    }
    
    @objc func ScreenUnlocked(){
        screenIsLocked = false
        lastActivity = Date()
    }
    
    @objc func timerWentOff(){
        DispatchQueue.main.async{
            self.update()
        }
    }
    
    @IBAction func AllowedInactivityTxtFieldChanged(_ sender: Any) {
        updateAllowedInactivity()
    }
    
    @IBAction func SaveBtnPressed(_ sender: Any) {
        updateAllowedInactivity()
    }
    
    func updateAllowedInactivity(){
        if let newReminderWaitTime = Int(allowedInactivityTxtField.stringValue){
            UserPreferences.SetAllowedInactivity(newReminderWaitTime)
            allowedInactivityLabel.stringValue = "Saved!"
        }else{
            allowedInactivityLabel.stringValue = "Invalid Time Entered!"
            allowedInactivityTxtField.stringValue = "\(UserPreferences.GetAllowedInactivity())"
        }
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(revertAllowedInactivityLabel), userInfo: nil, repeats: false)
    }
    
    @objc func revertAllowedInactivityLabel(){
        allowedInactivityLabel.stringValue = ALLOWED_INACTIVITY_LABEL_TEXT
    }
    
    @IBAction func PauseBtnPressed(_ sender: Any) {
        paused = !paused
        if (paused){
            PauseBtn.title = "Unpause"
        }else{
            PauseBtn.title = "Pause"
            lastActivity = Date()
        }
    }
    
}
