//
//  PostDetailsViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/15/21.
//

import UIKit

class PostDetailsViewController: UIViewController {
    
    var post: Post?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.darkGray.cgColor
        
        titleLabel.text = post?.title
        createdByLabel.text = "by \((post?.createdBy?.firstName)!) \((post?.createdBy?.lastName)!)"
        createdOnLabel.text = Utilities.getFormattedDateString((post?.createdAt)!)
        descriptionTextView.text = post?.body!
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
