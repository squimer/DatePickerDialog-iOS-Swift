//
//  DatePicker.swift

import Foundation
import UIKit
import QuartzCore


class DatePickerDialog: UIView {
    
    /* Consts */
    private let kDatePickerDialogDefaultButtonHeight: CGFloat = 50
    private let kDatePickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kDatePickerDialogCornerRadius: CGFloat = 7
    private let kDatePickerDialogCancelButtonTag: Int = 1
    private let kDatePickerDialogDoneButtonTag: Int = 2
    
    /* Views */
    private var dialogView: UIView!
    private var titleLabel: UILabel!
    private var datePicker: UIDatePicker!
    private var cancelButton: UIButton!
    private var doneButton: UIButton!
    
    /* Vars */
    private var title: String!
    private var doneButtonTitle: String!
    private var cancelButtonTitle: String!
    private var defaultDate: NSDate!
    private var datePickerMode: UIDatePickerMode!
    private var callback: ((date: NSDate) -> Void)!
    
    
    /* Overrides */
    init() {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* Handle device orientation changes */
    func deviceOrientationDidChange(notification: NSNotification) {
        /* TODO */
    }
    
    /* Create the dialog view, and animate opening the dialog */
    func show(title: String, datePickerMode: UIDatePickerMode = .DateAndTime, callback: ((date: NSDate) -> Void)) {
        show(title, doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: datePickerMode, callback: callback)
    }
    
    func show(title: String, doneButtonTitle: String, cancelButtonTitle: String, defaultDate: NSDate = NSDate(), datePickerMode: UIDatePickerMode = .DateAndTime, callback: ((date: NSDate) -> Void)) {
        self.title = title
        self.doneButtonTitle = doneButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.datePickerMode = datePickerMode
        self.callback = callback
        self.defaultDate = defaultDate
        
        self.dialogView = createContainerView()
        
        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.addSubview(self.dialogView!)
        
        /* Attached to the top most window (make sure we are using the right orientation) */
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        switch(interfaceOrientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            let t: Double = M_PI * 270 / 180
            self.transform = CGAffineTransformMakeRotation(CGFloat(t))
            break
            
        case UIInterfaceOrientation.LandscapeRight:
            let t: Double = M_PI * 90 / 180
            self.transform = CGAffineTransformMakeRotation(CGFloat(t))
            break
            
        case UIInterfaceOrientation.PortraitUpsideDown:
            let t: Double = M_PI * 180 / 180
            self.transform = CGAffineTransformMakeRotation(CGFloat(t))
            break
            
        default:
            break
        }
        
        self.frame = CGRectMake(0, 0, self.frame.width, self.frame.size.height)
        UIApplication.sharedApplication().windows.first!.addSubview(self)
        
        /* Anim */
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }
    
    /* Dialog close animation then cleaning and removing the view from the parent */
    private func close() {
        let currentTransform = self.dialogView.layer.transform
        
        let startRotation = (self.valueForKeyPath("layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + M_PI * 270 / 180), 0, 0, 0)
        
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
            }) { (finished: Bool) -> Void in
                for v in self.subviews {
                    v.removeFromSuperview()
                }
                
                self.removeFromSuperview()
        }
    }
    
    /* Creates the container view here: create the dialog, then add the custom content and buttons */
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        let dialogSize = CGSizeMake(
            300,
            230
                + kDatePickerDialogDefaultButtonHeight
                + kDatePickerDialogDefaultButtonSpacerHeight)
        
        // For the black background
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        
        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height))
        
        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).CGColor,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).CGColor,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).CGColor]
        
        let cornerRadius = kDatePickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, atIndex: 0)
        
        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).CGColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius + 5) / 2, 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.blackColor().CGColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).CGPath
        
        // There is a line above the button
        let lineView = UIView(frame: CGRectMake(0, dialogContainer.bounds.size.height - kDatePickerDialogDefaultButtonHeight - kDatePickerDialogDefaultButtonSpacerHeight, dialogContainer.bounds.size.width, kDatePickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        // ˆˆˆ
        
        //Title
        self.titleLabel = UILabel(frame: CGRectMake(10, 10, 280, 30))
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.font = UIFont.boldSystemFontOfSize(17)
        self.titleLabel.text = self.title
        dialogContainer.addSubview(self.titleLabel)
        
        self.datePicker = UIDatePicker(frame: CGRectMake(0, 30, 0, 0))
        self.datePicker.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
        self.datePicker.frame.size.width = 300
        self.datePicker.datePickerMode = self.datePickerMode
        self.datePicker.date = self.defaultDate
        dialogContainer.addSubview(self.datePicker)
        
        // Add the buttons
        addButtonsToView(dialogContainer)
        
        return dialogContainer
    }
    
    /* Add buttons to container */
    private func addButtonsToView(container: UIView) {
        let buttonWidth = container.bounds.size.width / 2
        
        self.cancelButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.cancelButton.frame = CGRectMake(
            0,
            container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            buttonWidth,
            kDatePickerDialogDefaultButtonHeight
        )
        self.cancelButton.tag = kDatePickerDialogCancelButtonTag
        self.cancelButton.setTitle(self.cancelButtonTitle, forState: UIControlState.Normal)
        self.cancelButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: UIControlState.Highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.cancelButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.cancelButton.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(self.cancelButton)
        
        self.doneButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.doneButton.frame = CGRectMake(
            buttonWidth,
            container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            buttonWidth,
            kDatePickerDialogDefaultButtonHeight
        )
        self.doneButton.tag = kDatePickerDialogDoneButtonTag
        self.doneButton.setTitle(self.doneButtonTitle, forState: UIControlState.Normal)
        self.doneButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.doneButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: UIControlState.Highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.doneButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.doneButton.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(self.doneButton)
    }
    
    func buttonTapped(sender: UIButton!) {
        if sender.tag == kDatePickerDialogDoneButtonTag {
            self.callback(date: self.datePicker.date)
        } else if sender.tag == kDatePickerDialogCancelButtonTag {
            //There's nothing do to here \o\
        }
        
        close()
    }
    
    /* Helper function: count and return the screen's size */
    func countScreenSize() -> CGSize {
        var screenWidth = UIScreen.mainScreen().bounds.size.width
        var screenHeight = UIScreen.mainScreen().bounds.size.height
        
        let interfaceOrientaion = UIApplication.sharedApplication().statusBarOrientation
        
        if UIInterfaceOrientationIsLandscape(interfaceOrientaion) {
            let tmp = screenWidth
            screenWidth = screenHeight
            screenHeight = tmp
        }
        
        return CGSizeMake(screenWidth, screenHeight)
    }
    
}
