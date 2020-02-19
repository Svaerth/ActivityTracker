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
                recordPreviousActivityPhase(type:oldValue)
                activityTypeLastChanged = Date()
            }
        }
    }
    
    //MARK: iboutlets
    @IBOutlet weak var PauseBtn: NSButton!
    @IBOutlet weak var scoldingText: NSTextField!
    @IBOutlet weak var scoldingTextHeight: NSLayoutConstraint!
    @IBOutlet weak var SessionBtn: NSButton!
    @IBOutlet weak var ActivityDistanceControl: PreferenceControl!
    @IBOutlet weak var AllowedInactivityControl: PreferenceControl!
    @IBOutlet weak var currentDirectoryLabel: NSTextField!
    
    // MARK: event methods
    
    override func viewDidLoad() {
        
        UserPreferences.RegisterDefaultPreferences()
        
        //setting up update timer
        _ = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(updateTimerWentOff), userInfo: nil, repeats: true)
        
        SetupEventMonitoring()
    }
    
    override func viewWillAppear() {
        
        scoldingTextInitialHeight = scoldingText.bounds.size.height
        scoldingTextHeight.constant = 0
        
        ActivityDistanceControl.setup(description: "Allowed Activity Dist.", getTextFieldValue: { () -> Int in
            return UserPreferences.GetAllowedActivityDistance()
        }) { (newValue) in
            UserPreferences.SetAllowedActivityDistance(newValue)
        }
        
        AllowedInactivityControl.setup(description: "Allowed Inactivity", getTextFieldValue: { () -> Int in
            return UserPreferences.GetAllowedInactivity()
        }) { (newValue) in
            UserPreferences.SetAllowedInactivity(newValue)
        }
        
        currentDirectoryLabel.stringValue = UserPreferences.GetSessionStorageDirectory()
        
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
    
    @IBAction func SessionBtnPressed(_ sender: Any) {
        //ending the session
        if currentSession != nil{
            SessionBtn.title = "Start Session"
            recordPreviousActivityPhase(type:currentActivityType)
            currentSession?.saveToDisk()
            currentSession = nil
        }
        //starting the session
        else{
            currentSession = Session()
            SessionBtn.title = "End Session"
        }
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
    
    @IBAction func ChangeDirBtnPressed(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        dialog.title = "Choose a .txt file";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true;
        dialog.canCreateDirectories = true;
        dialog.allowsMultipleSelection = false;
        dialog.directoryURL = URL(fileURLWithPath: UserPreferences.GetSessionStorageDirectory())

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if (result != nil) {
                let path = result!.path
                currentDirectoryLabel.stringValue = path
                UserPreferences.SetSessionStorageDirectory(path)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    // MARK: helper methods
    
    func recordPreviousActivityPhase(type: ActivityType){
        if let _currentSession = currentSession{
            let startTime = activityTypeLastChanged < _currentSession.date ? _currentSession.date : activityTypeLastChanged
            currentSession!.activityPhases.append(ActivityPhase(startTime: startTime, endTime: Date(), activityType: type))
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
