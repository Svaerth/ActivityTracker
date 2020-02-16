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
    
    // MARK: constants
    let EVENTS_TO_MONITOR:NSEvent.EventTypeMask = [.keyDown,.mouseMoved,.scrollWheel,.leftMouseDown,.rightMouseDown,.otherMouseDown,.leftMouseDragged,.rightMouseDragged]
    let ALLOWED_INACTIVITY_LABEL_TEXT = "How long to wait before showing reminder? (Seconds)"
    
    // MARK: other variables
    var scoldingTextInitialHeight:CGFloat = 0
    var currentSession:Session? = nil
    var lastActivity:Date = Date()
    var beginningActivity:Date = Date()
    var screenIsLocked = false
    var paused = false
    var inputOccurred = false
    var activityTypeLastChanged = Date()
    var currentActivityType:ActivityType = .active {
        didSet{
            if (currentActivityType != oldValue){
                if (oldValue == .scolded){
                    hideScoldingText()
                }
                let ap = ActivityPhase(startTime: activityTypeLastChanged, endTime: Date(), activityType: oldValue)
                print("\(ap)")
                currentSession?.activityPhases.append(ap)
                activityTypeLastChanged = Date()
            }
        }
    }
    
    //MARK: iboutlets
    @IBOutlet weak var PauseBtn: NSButton!
    @IBOutlet weak var allowedInactivityTxtField: NSTextField!
    @IBOutlet weak var allowedInactivityLabel: NSTextField!
    @IBOutlet weak var scoldingText: NSTextField!
    @IBOutlet weak var scoldingTextHeight: NSLayoutConstraint!
    
    // MARK: event methods
    
    override func viewDidLoad() {
        
        currentSession = Session(date:Date(),activityPhases:[])
        
        //setting up update timer
        _ = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateTimerWentOff), userInfo: nil, repeats: true)
        
        SetupEventMonitoring()
    }
    
    override func viewWillAppear() {
        scoldingTextInitialHeight = scoldingText.bounds.size.height
        scoldingTextHeight.constant = 0
        
        allowedInactivityTxtField.stringValue = "\(UserPreferences.GetAllowedInactivity())"
        allowedInactivityLabel.stringValue = ALLOWED_INACTIVITY_LABEL_TEXT
    }
    
    @objc func ScreenLocked(){
        screenIsLocked = true
        currentActivityType = .screenLocked
    }
    
    @objc func ScreenUnlocked(){
        screenIsLocked = false
        currentActivityType = .active
        lastActivity = Date()
    }
    
    @objc func updateTimerWentOff(){
        
        DispatchQueue.main.async{
            
            if (self.screenIsLocked == false && self.paused == false){
                
                if self.inputOccurred{
                    self.currentActivityType = .active
                    self.lastActivity = Date()
                }
                
                //showing reminder popup if you've been inactive too long
                if (Date().timeIntervalSince(self.lastActivity) > TimeInterval(UserPreferences.GetAllowedInactivity())
                    && self.currentActivityType != .scolded){
                    self.scoldUser()
                }
                
                //switching to inactive state if enough time has passed since last activity
                if (self.currentActivityType == .active
                    && Date().timeIntervalSince(self.lastActivity) > TimeInterval(UserPreferences.GetAllowedActivityDistance())){
                    self.currentActivityType = .inactive
                }
                
                
                //resetting input occurred bool
                self.inputOccurred = false
                
            }
            
        }
        
    }
    
    @IBAction func AllowedInactivityTxtFieldChanged(_ sender: Any) {
        updateAllowedInactivity()
    }
    
    @IBAction func SaveBtnPressed(_ sender: Any) {
        updateAllowedInactivity()
    }
    
    @IBAction func PauseBtnPressed(_ sender: Any) {
        paused = !paused
        if (paused){
            currentActivityType = .paused
            PauseBtn.title = "Unpause"
        }else{
            currentActivityType = .active
            PauseBtn.title = "Pause"
            lastActivity = Date()
        }
    }
    
    // MARK: helper methods
    
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
    
    func showScoldingText(){
        NSAnimationContext.runAnimationGroup{context in
            context.duration = 0.25
            scoldingText.animator().alphaValue = 1
            scoldingTextHeight.animator().constant = scoldingTextInitialHeight
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    func hideScoldingText(){
        NSAnimationContext.runAnimationGroup{context in
            context.duration = 0.25
            scoldingText.animator().alphaValue = 0
            scoldingTextHeight.animator().constant = 0
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    func scoldUser(){
        NSApplication.shared.activate(ignoringOtherApps: true)
        showScoldingText()
        currentActivityType = .scolded
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
    
}
