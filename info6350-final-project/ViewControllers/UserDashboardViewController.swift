//
//  UserDashboardViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/12/21.
//

import UIKit
import FirebaseAuth

class UserDashboardViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func doLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.gotoAuth()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            showError("error signing out")
        }
    }
    
    func gotoAuth() {
        navigationController?.popToRootViewController(animated: true)
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
