import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var textField: UITextField!

	/* Overrides */
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	/* IBActions */
	@IBAction func datePickerTapped(sender: AnyObject) {
		DatePickerDialog().show("DatePickerDialog", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
			(date) -> Void in

			if let dt = date {
				self.textField.text = "\(dt)"
            } else {
                print("")
            }
		}
	}

}