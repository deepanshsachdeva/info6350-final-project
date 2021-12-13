//
//  LoginViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/12/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailInput.delegate = self
        passwordInput.delegate = self
        
        setupElements()
    }
    
    func setupElements() {
        clearError()
        
        emailInput.text = ""
        passwordInput.text = ""
    }
    
    func clearError() {
        errorLabel.text = "error"
        errorLabel.alpha = 0
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func validateFields() -> String? {
        if Utilities.sanitizeInputField(emailInput) == "" ||
            Utilities.sanitizeInputField(passwordInput) == "" {
            return "Please fill in all fields."
        }
        
        if Utilities.isEmailvalid(Utilities.sanitizeInputField(emailInput)) == false {
            return "Invalid email address."
        }
        
        return nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
    
    @IBAction func doLogin(_ sender: Any) {
        clearError()
        
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            let email = Utilities.sanitizeInputField(emailInput)
            let password = Utilities.sanitizeInputField(passwordInput)
            
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    self.showError(error!.localizedDescription)
                }
                else {
                    self.gotoUserDashboard()
                }
            }
        }
    }
    
    func gotoUserDashboard() {
        let userDashboardViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.userDashboardViewController) as? UserDashboardViewController
        
        self.navigationController?.pushViewController(userDashboardViewController!, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
