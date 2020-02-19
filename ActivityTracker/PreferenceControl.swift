//
//  PreferenceControl.swift
//  ActivityTracker
//
//  Created by Will Anderson on 2/17/20.
//  Copyright © 2020 Will Anderson. All rights reserved.
//

import Foundation
import AppKit

class PreferenceControl : NSView , NSTextFieldDelegate{
    
    var label:NSTextField = NSTextField(labelWithString: "placeholder")
    var textfield:NSTextField = NSTextField(string: "placeholder")
    var button:NSButton = NSButton(title: "Apply", target: nil, action: nil)
    
    var labelText:String? = nil
    var getTextFieldValue:(() -> Int)? = nil
    var onSubmission:((Int) -> ())? = nil
    
    var revertLabelTimer:Timer? = nil
    
    override init(frame: CGRect){
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        commonInit()
    }
    
    private func commonInit(){
        
        let stackView = NSStackView(views: [label,textfield,button])
        stackView.orientation = .vertical
        stackView.alignment = .leading
        addSubview(stackView)
        
        //label setup
        _ = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: -10).isActive = true
        _ = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20).isActive = true
        
        //textfield setup
        textfield.delegate = self
        _ = NSLayoutConstraint(item: textfield, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        _ = NSLayoutConstraint(item: textfield, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30).isActive = true
        
        //button setup
        button.bezelStyle = .rounded
        button.target = self
        button.action = #selector(submit)
        _ = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        _ = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30).isActive = true
        
    }
    
    func setup(description: String, getTextFieldValue: @escaping () -> Int, onSubmission: @escaping (Int) -> ()){
        self.labelText = description
        self.getTextFieldValue = getTextFieldValue
        self.onSubmission = onSubmission
        
        label.stringValue = description
        textfield.stringValue = "\(getTextFieldValue())"
    }
    
    @objc func submit(){
        if let newValue = Int(textfield.stringValue){
            onSubmission?(newValue)
            label.stringValue = "Saved!"
        }else{
            if (getTextFieldValue != nil){
                textfield.stringValue = "\(getTextFieldValue!())"
            }
            label.stringValue = "Invalid Input!"
        }
        
        if (revertLabelTimer != nil){
            revertLabelTimer?.invalidate()
        }
        revertLabelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(revertLabel), userInfo: nil, repeats: false)
        
    }
    
    @objc func revertLabel(){
        label.stringValue = labelText ?? "No Description Available"
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        //if the ENTER key was pressed while the textfield was focused
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            submit()
            return true
        }
        return false
    }
    
}
