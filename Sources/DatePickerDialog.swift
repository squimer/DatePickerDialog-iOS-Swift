import Foundation
import UIKit

private extension Selector {
    static let buttonTapped = #selector(DatePickerDialog.buttonTapped)
    static let deviceOrientationDidChange = #selector(DatePickerDialog.deviceOrientationDidChange)
}

public class DatePickerDialog: UIView {
    public typealias DatePickerCallback = (date: NSDate?) -> Void

    // MARK: - Constants
    private let kDatePickerDialogDefaultButtonHeight:       CGFloat = 50
    private let kDatePickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kDatePickerDialogCornerRadius:              CGFloat = 7
    private let kDatePickerDialogDoneButtonTag:             Int     = 1

    // MARK: - Views
    private var dialogView:   UIView!
    private var titleLabel:   UILabel!
    public var datePicker:    UIDatePicker!
    private var cancelButton: UIButton!
    private var doneButton:   UIButton!

    // MARK: - Variables
    private var defaultDate:    NSDate?
    private var datePickerMode: UIDatePickerMode?
    private var callback:       DatePickerCallback?

    // MARK: - Dialog initialization
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height))
        setupView()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.dialogView = createContainerView()

        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.mainScreen().scale

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale

        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)

        self.addSubview(self.dialogView!)
    }

    /// Handle device orientation changes
    func deviceOrientationDidChange(notification: NSNotification) {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        let screenSize = countScreenSize()
        let dialogSize = CGSize(width: 300, height: 230 + kDatePickerDialogDefaultButtonHeight + kDatePickerDialogDefaultButtonSpacerHeight)
        dialogView.frame = CGRect(x: (screenSize.width - dialogSize.width) / 2, y: (screenSize.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height)
    }

    /// Create the dialog view, and animate opening the dialog
    public func show(title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", defaultDate: NSDate = NSDate(), minimumDate: NSDate? = nil, maximumDate: NSDate? = nil, datePickerMode: UIDatePickerMode = .DateAndTime, callback: DatePickerCallback) {
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, forState: .Normal)
        self.cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
        self.datePickerMode = datePickerMode
        self.callback = callback
        self.defaultDate = defaultDate
        self.datePicker.datePickerMode = self.datePickerMode ?? .Date
        self.datePicker.date = self.defaultDate ?? NSDate()
        self.datePicker.maximumDate = maximumDate
        self.datePicker.minimumDate = minimumDate

        /* Add dialog to main window */
        guard let appDelegate = UIApplication.sharedApplication().delegate else { fatalError() }
        guard let window = appDelegate.window else { fatalError() }
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: .deviceOrientationDidChange, name: UIDeviceOrientationDidChangeNotification, object: nil)

        /* Anim */
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: .CurveEaseInOut,
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }

    /// Dialog close animation then cleaning and removing the view from the parent
    private func close() {
        NSNotificationCenter.defaultCenter().removeObserver(self)

        let currentTransform = self.dialogView.layer.transform

        let startRotation = (self.valueForKeyPath("layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + M_PI * 270 / 180), 0, 0, 0)

        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1

        UIView.animateWithDuration(0.2,
            delay: 0,
            options: [],
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
        }) { (finished) in
            for v in self.subviews {
                v.removeFromSuperview()
            }

            self.removeFromSuperview()
            self.setupView()
        }
    }

    /// Creates the container view here: create the dialog, then add the custom content and buttons
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        let dialogSize = CGSize(
            width: 300,
            height: 230
                + kDatePickerDialogDefaultButtonHeight
                + kDatePickerDialogDefaultButtonSpacerHeight)

        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)

        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRect(x: (screenSize.width - dialogSize.width) / 2, y: (screenSize.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height))

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
        dialogContainer.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2, height: 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.blackColor().CGColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).CGPath

        // There is a line above the button
        let lineView = UIView(frame: CGRect(x: 0, y: dialogContainer.bounds.size.height - kDatePickerDialogDefaultButtonHeight - kDatePickerDialogDefaultButtonSpacerHeight, width: dialogContainer.bounds.size.width, height: kDatePickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)

        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 280, height: 30))
        self.titleLabel.textAlignment = .Center
        self.titleLabel.font = UIFont.boldSystemFontOfSize(17)
        dialogContainer.addSubview(self.titleLabel)

        self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 30, width: 0, height: 0))
        self.datePicker.autoresizingMask = .FlexibleRightMargin
        self.datePicker.frame.size.width = 300
        self.datePicker.frame.size.height = 216
        dialogContainer.addSubview(self.datePicker)

        // Add the buttons
        addButtonsToView(dialogContainer)

        return dialogContainer
    }

    /// Add buttons to container
    private func addButtonsToView(container: UIView) {
        let buttonWidth = container.bounds.size.width / 2

        self.cancelButton = UIButton(type: .Custom) as UIButton
        self.cancelButton.frame = CGRect(
            x: 0,
            y: container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kDatePickerDialogDefaultButtonHeight
        )
        self.cancelButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: .Normal)
        self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: .Highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.cancelButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.cancelButton.addTarget(self, action: .buttonTapped, forControlEvents: .TouchUpInside)
        container.addSubview(self.cancelButton)

        self.doneButton = UIButton(type: .Custom) as UIButton
        self.doneButton.frame = CGRect(
            x: buttonWidth,
            y: container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kDatePickerDialogDefaultButtonHeight
        )
        self.doneButton.tag = kDatePickerDialogDoneButtonTag
        self.doneButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: .Normal)
        self.doneButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: .Highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.doneButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.doneButton.addTarget(self, action: .buttonTapped, forControlEvents: .TouchUpInside)
        container.addSubview(self.doneButton)
    }

    func buttonTapped(sender: UIButton!) {
        if sender.tag == kDatePickerDialogDoneButtonTag {
            self.callback?(date: self.datePicker.date)
        } else {
            self.callback?(date: nil)
        }

        close()
    }

    // MARK: - Helpers

    /// Count and return the screen's size
    func countScreenSize() -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height

        return CGSize(width: screenWidth, height: screenHeight)
    }

}
