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
    
    let db = Firestore.firestore()

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
    
    func resetFields() {
        firstNameInput.text = ""
        lastNameInput.text = ""
        emailInput.text = ""
        passwordInput.text = ""
        confirmPasswordInput.text = ""
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
        if Utilities.sanitizeTextInput(firstNameInput.text!) == "" || Utilities.sanitizeTextInput(lastNameInput.text!) == "" ||
            Utilities.sanitizeTextInput(emailInput.text!) == "" ||
            Utilities.sanitizeTextInput(passwordInput.text!) == "" ||
            Utilities.sanitizeTextInput(confirmPasswordInput.text!) == "" {
            return "Please fill in all fields."
        }
        
        let emailInput = Utilities.sanitizeTextInput(emailInput.text!)
        
        if Utilities.isEmailvalid(emailInput) == false {
            return "Invalid email address."
        }
        
        let cleanedPassword = Utilities.sanitizeTextInput(passwordInput.text!)
        
        let cleanedConfirmPassword = Utilities.sanitizeTextInput(confirmPasswordInput.text!)
        
        if cleanedPassword != cleanedConfirmPassword {
            return "Password & Confirm Password don't match."
        }
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Password must be min 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    @IBAction func doRegister(_ sender: UIButton) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            let firstName = Utilities.sanitizeTextInput(firstNameInput.text!)
            let lastName = Utilities.sanitizeTextInput(lastNameInput.text!)
            let email = Utilities.sanitizeTextInput(emailInput.text!)
            let password = Utilities.sanitizeTextInput(passwordInput.text!)
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (result,err) in
                if err != nil {
                    switch AuthErrorCode(rawValue: err!._code) {
                        case .emailAlreadyInUse : self.showError("Email already registered")
                        default: self.showError("error creating user")
                    }
                } else {
                    let newUser = User(uid: (result?.user.uid)!, firstName: firstName, lastName: lastName, email: email)
                    
                    do {
                        let _ = try self.db.collection("users").addDocument(from: newUser)
                    } catch {
                        self.showError("error storing user")
                    }
                    
                    self.resetFields()
                    self.performSegue(withIdentifier: "afterRegisterSuccess", sender: nil)
                }
            })
        }
    }
    
    @IBAction func doCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
