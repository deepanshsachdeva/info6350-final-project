//
//  PostCRUViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/14/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostCRUViewController: UIViewController, UITextFieldDelegate {
    
    var post:Post?
    
    let db = Firestore.firestore()
    
    let user = Auth.auth().currentUser

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastUpdatedAtLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextView!
    @IBOutlet weak var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        descriptionInput.layer.borderWidth = 0.5
        descriptionInput.layer.borderColor = UIColor.lightGray.cgColor
        
        if post != nil {
            actionButton.setTitle("Save", for: .normal)
            
            titleLabel.text = "Update Post"
            titleInput.text = post?.title
            lastUpdatedAtLabel.text = "last updated at \(Utilities.getFormattedDateString(post!.lastUpdated!))"
            descriptionInput.text = post?.body
        } else {
            actionButton.setTitle("Post", for: .normal)
            
            titleLabel.text = "Create New Post"
            descriptionInput.text = ""
            lastUpdatedAtLabel.isHidden = true
        }
        
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
        if Utilities.sanitizeTextInput(titleInput.text!) == "" || Utilities.sanitizeTextInput(descriptionInput.text!) == "" {
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    @IBAction func doAction(_ sender: UIButton) {
        let error = validateFields()
        
        if error != nil {
            self.showError(error!)
        } else {
            let title = Utilities.sanitizeTextInput(titleInput.text!)
            let body = Utilities.sanitizeTextInput(descriptionInput.text!)
            
            var alertMessage:String = ""
            
            if post != nil {
                db.collection("posts").document((post?.id)!).updateData([
                    "title": title,
                    "body": body,
                    "lastUpdated": FieldValue.serverTimestamp()
                ]) { err in
                    if let err = err {
                        self.showError("error saving data")
                    }
                }
                
                alertMessage = "post updated successfully"
            } else {
                db.collection("users").whereField("uid", isEqualTo: user?.uid).getDocuments() {(querySnapshot, err) in
                    if let error = err {
                        print(error)
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self.showError("error saving data")
                        return
                    }
                    
                    let dbUser = documents.compactMap { queryDocumentSnapshot -> User? in
                        return try? queryDocumentSnapshot.data(as: User.self)
                    }[0]
                    
                    let newPost = Post(title: title, body: body, createdByUID: (self.user?.uid)!, createdByFullName: "\(dbUser.firstName) \(dbUser.lastName)")
                    
                    do {
                        let _ = try self.db.collection("posts").addDocument(from: newPost)
                    } catch {
                        self.showError("error creating post")
                    }
                }
                
                alertMessage = "post created successfully"
            }
            
            let alert = UIAlertController(title: "Message", message: alertMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            
            present(alert, animated: true, completion: nil)
        }
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
