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
    
    var currentSession:Session! = nil
    var lastActivity:Date = Date()
    var beginningActivity:Date = Date()
    
    var screenIsLocked = false
    var paused = false
    var activityTypeLastChanged = Date()
    var currentActivityType:ActivityType = .active {
        didSet{
            if (currentActivityType != oldValue){
                if (oldValue == .scolded){
                    hideScoldingText()
                }
                currentSession.activityPhases.append(ActivityPhase(startTime: activityTypeLastChanged, endTime: Date(), activityType: currentActivityType))
                activityTypeLastChanged = Date()
            }
        }
    }
    
    //event variables
    var inputOccurred = false
    
    @IBOutlet weak var PauseBtn: NSButton!
    @IBOutlet weak var allowedInactivityTxtField: NSTextField!
    @IBOutlet weak var allowedInactivityLabel: NSTextField!
    @IBOutlet weak var scoldingText: NSTextField!
    @IBOutlet weak var scoldingTextHeight: NSLayoutConstraint!
    var scoldingTextInitialHeight:CGFloat = 0
    
    override func viewDidLoad() {
        
        currentSession = Session(date:Date(),activityPhases:[])
        
        //setting up update timer
        _ = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(timerWentOff), userInfo: nil, repeats: true)
        
        SetupEventMonitoring()
    }
    
    override func viewWillAppear() {
        scoldingTextInitialHeight = scoldingText.bounds.size.height
        scoldingTextHeight.constant = 0
        
        allowedInactivityTxtField.stringValue = "\(UserPreferences.GetAllowedInactivity())"
        allowedInactivityLabel.stringValue = ALLOWED_INACTIVITY_LABEL_TEXT
    }
    
    func update(){
        
        if (screenIsLocked == false && paused == false){
            
            var lastActivityShouldUpdate = false
            
            if inputOccurred{
                currentActivityType = .active
                lastActivityShouldUpdate = true
            }
            
            //showing reminder popup if you've been inactive too long
            if (Date().timeIntervalSince(lastActivity) > TimeInterval(UserPreferences.GetAllowedInactivity())
                && currentActivityType != .scolded){
                    scoldUser()
            }
            
            if (currentActivityType == .active
                && Date().timeIntervalSince(lastActivity) > TimeInterval(UserPreferences.GetAllowedActivityDistance())){
                currentActivityType = .inactive
            }
            
            inputOccurred = false
            
            if lastActivityShouldUpdate{
                lastActivity = Date()
            }
            
        }
        
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
    
    func currentlyInactive() -> Bool{
        return Date().timeIntervalSince(lastActivity) > TimeInterval(UserPreferences.GetAllowedInactivity())
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
        currentActivityType = .screenLocked
    }
    
    @objc func ScreenUnlocked(){
        screenIsLocked = false
        currentActivityType = .active
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
            currentActivityType = .paused
            PauseBtn.title = "Unpause"
        }else{
            currentActivityType = .active
            PauseBtn.title = "Pause"
            lastActivity = Date()
        }
    }
    
}
