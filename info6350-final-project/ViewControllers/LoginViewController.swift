//
//  LoginViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/12/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let ds = DataStore.shared

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
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
    
    func resetFields() {
        emailInput.text = ""
        passwordInput.text = ""
    }
    
    func validateFields() -> String? {
        if Utilities.sanitizeTextInput(emailInput.text!) == "" ||
            Utilities.sanitizeTextInput(passwordInput.text!) == "" {
            return "Please fill in all fields."
        }
        
        let emailInput = Utilities.sanitizeTextInput(emailInput.text!)
        
        if Utilities.isEmailvalid(emailInput) == false {
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
        
        loginButton.isEnabled = false
        
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            let email = Utilities.sanitizeTextInput(emailInput.text!)
            let password = Utilities.sanitizeTextInput(passwordInput.text!)
            
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    print(error!._code)
                    switch AuthErrorCode(rawValue: error!._code) {
                        case .networkError:
                            self.showError("Internet connection not available")
                    case .invalidCredential, .invalidEmail, .wrongPassword:
                            self.showError("Invalid Credentials")
                        default:
                            self.showError(error!.localizedDescription)
                    }
                }
                else {
                    let authUser = result?.user
                    
                    self.ds.authUser = self.ds.getUserByUID(authUser?.uid as! String)
                    
                    self.resetFields()
                    self.performSegue(withIdentifier: "afterLoginSuccess", sender: nil)
                }
            }
        }
    }
    
    func gotoUserDashboard() {
        let userPostViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.userPostsViewController) as? UserPostsTableViewController
        
        navigationController?.pushViewController(userPostViewController!, animated: true)
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
