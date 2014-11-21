//
//  DatePickerDialog.swift
//  DatePickerDialogExample
//
//  Created by vinicius on 11/20/14.
//  Copyright (c) 2014 Squimer. All rights reserved.
//

import UIKit
import QuartzCore

protocol DatePickerDialogDelegate {
    
    func datePickerDialog(didSelect date: NSDate, from tag: String)
    
}

class DatePickerDialog: UIView {
    
    /* Consts */
    let backgroundAlpha:   CGFloat        = 0.5
    let animationDuration: NSTimeInterval = 0.25
    let cornerRadius:      CGFloat        = 8.0
    
    /* IBOutlets */
    @IBOutlet weak var datePicker: UIDatePicker!
    
    /* Local vars */
    var datePickerTag: String = ""
    var delegate: DatePickerDialogDelegate?
    
    /* Overrides */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureOverlay()
        configureNib()
        
        self.hidden = true
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /* IBActions */
    @IBAction func cancelTapped(sender: AnyObject) {
        hidePicker()
    }
    
    @IBAction func selectTapped(sender: AnyObject) {
        hidePicker()
        if self.delegate != nil {
            self.delegate!.datePickerDialog(didSelect: self.datePicker.date, from: self.datePickerTag)
        }
    }
    
    /* Helper functions */
    private func configureOverlay() {
        var overlayView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = self.backgroundAlpha
        self.addSubview(overlayView)
    }
    
    private func configureNib() {
        var nibContents = NSBundle.mainBundle().loadNibNamed("DatePickerDialog", owner: self, options: nil)
        var pickerView = nibContents[0] as UIView
        pickerView.frame = CGRectMake(15, (self.frame.size.height / 2) - (pickerView.frame.size.height / 2) - 16, frame.size.width - 30, pickerView.frame.size.height)
        
        //If is running iOS 7
        var c: AnyObject? = objc_getClass("UIAlertController".cStringUsingEncoding(NSASCIIStringEncoding))
        if c == nil {
            pickerView.frame.origin.x = 8
        }
        
        /* Corners */
        pickerView.layer.cornerRadius = self.cornerRadius
        
        /* Shadow */
        self.layer.masksToBounds = false
        self.layer.cornerRadius  = self.cornerRadius
        self.layer.shadowOffset  = CGSizeMake(-1, 1)
        self.layer.shadowRadius  = 10
        self.layer.shadowOpacity = 0.5
        
        self.addSubview(pickerView)
    }
    
    func showPickerWithTag(tag: String) {
        self.datePickerTag = tag
        self.hidden = false
        self.alpha = 0.0
        UIView.animateWithDuration(self.animationDuration, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
    func hidePicker() {
        UIView.animateWithDuration(self.animationDuration, animations: { () -> Void in
            self.alpha = 0.0
        }) { (value: Bool) -> Void in
            self.hidden = true
        }
    }
    
}
