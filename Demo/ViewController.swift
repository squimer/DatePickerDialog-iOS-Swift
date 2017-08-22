import UIKit
import DatePickerDialog

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!

    @IBAction func datePickerTapped(sender: AnyObject) {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = -3
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)

        let datePicker = DatePickerDialog(textColor: .red, buttonColor: .red, font: UIFont.boldSystemFont(ofSize: 17), showCancelButton: true)
        datePicker.show("DatePickerDialog", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: threeMonthAgo, maximumDate: currentDate, datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.textField.text = formatter.string(from: dt)
            }
        }
    }
}
