import UIKit
import DatePickerDialog

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!

    @IBAction func datePickerTapped(sender: AnyObject) {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = -3
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)

        DatePickerDialog().show(title: "DatePickerDialog", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: threeMonthAgo, maximumDate: currentDate, datePickerMode: .date) { (date) in
            if let dt = date {
                self.textField.text = "\(dt)"
            }
        }
    }
}
