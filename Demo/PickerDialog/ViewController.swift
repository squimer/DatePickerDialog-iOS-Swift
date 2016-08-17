import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    /* Overrides */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* IBActions */
    @IBAction func datePickerTapped(sender: AnyObject) {
        let currentDate = NSDate()
        let dateComponents = NSDateComponents()
        dateComponents.month = -3
        let threeMonthAgo = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))
        
        DatePickerDialog().show("DatePickerDialog", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: threeMonthAgo, maximumDate: currentDate, datePickerMode: .Date) {
            (date) -> Void in
            if let dt = date {
                self.textField.text = "\(dt)"
            } else {
                print("")
            }
        }
        
    }
    
}
