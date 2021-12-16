//
//  PostCRUViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/14/21.
//

import UIKit
import CoreData

class PostCRUViewController: UIViewController {
    
    var post:Post!
    
    let ds = DataStore.shared
    let managedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!

    @IBOutlet weak var titleLabel: UILabel!
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
            descriptionInput.text = post?.body
        } else {
            actionButton.setTitle("Post", for: .normal)
            
            titleLabel.text = "Create New Post"
            descriptionInput.text = ""
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
            
            if post != nil {
                post?.title = title
                post?.body = body
                
                ds.saveContext()
            } else {
                let newPost = Post(context: managedContext)
                
                newPost.title = title
                newPost.body = body
                newPost.createdBy = ds.authUser
                
                ds.addPost(newPost)
            }
            
            self.navigationController?.popViewController(animated: true)
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
