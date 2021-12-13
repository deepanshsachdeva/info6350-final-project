//
//  RegisterViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/12/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var confirmPasswordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        firstNameInput.delegate = self
        lastNameInput.delegate = self
        emailInput.delegate = self
        passwordInput.delegate = self
        confirmPasswordInput.delegate = self
        
        clearError()
    }
    
    func clearError() {
        errorLabel.text = "error"
        errorLabel.alpha = 0
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
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
    
    func validateFields() -> String? {
        if Utilities.sanitizeInputField(firstNameInput) == "" || Utilities.sanitizeInputField(lastNameInput) == "" ||
            Utilities.sanitizeInputField(emailInput) == "" ||
            Utilities.sanitizeInputField(passwordInput) == "" ||
            Utilities.sanitizeInputField(confirmPasswordInput) == "" {
            return "Please fill in all fields."
        }
        
        if Utilities.isEmailvalid(Utilities.sanitizeInputField(emailInput)) == false {
            return "Invalid email address."
        }
        
        let cleanedPassword = Utilities.sanitizeInputField(passwordInput)
        
        let cleanedConfirmPassword = Utilities.sanitizeInputField(confirmPasswordInput)
        
        if cleanedPassword != cleanedConfirmPassword {
            return "Password & Confirm Password don't match."
        }
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    @IBAction func doRegister(_ sender: UIButton) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            let firstName = Utilities.sanitizeInputField(firstNameInput)
            let lastName = Utilities.sanitizeInputField(lastNameInput)
            let email = Utilities.sanitizeInputField(emailInput)
            let password = Utilities.sanitizeInputField(passwordInput)
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (result,err) in
                if err != nil {
                    self.showError("Error creating user")
                } else {
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": result!.user.uid ]) { (error) in
                        
                        if error != nil {
                            self.showError("Error saving user data")
                        }
                    }
                    
                    self.gotoUserDashboard()
                }
            })
        }
    }
    
    @IBAction func doCancel(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
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
