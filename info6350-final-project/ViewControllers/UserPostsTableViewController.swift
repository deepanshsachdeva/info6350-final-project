//
//  UserPostsTableViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/14/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserPostsTableViewController: UITableViewController {
    var posts:[Post] = []
    
    let db = Firestore.firestore()
    
    var isRefreshing:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout", style: .plain, target: self, action: #selector(doLogout)
        )
        
        isRefreshing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isRefreshing = true
        
        fetchData()
    }
    
    func fetchData() {
        let user = Auth.auth().currentUser
        
        db.collection("posts").whereField("createdByUID", isEqualTo: user?.uid).getDocuments() { (querySnapshot, err) in
            if let error = err {
                print(error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No posts")
                return
            }
            
            self.posts = documents.compactMap { queryDocumentSnapshot -> Post? in
                return try? queryDocumentSnapshot.data(as: Post.self)
            }
            
            self.isRefreshing = false
            self.tableView.reloadData()
        }
    }
    
    @objc private func doLogout() {
        let alert = UIAlertController(title: "Logout", message: "Confirm?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            do {
                try Auth.auth().signOut()
                self.navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        })
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = posts.count
        
        if count == 0 {
            if isRefreshing {
                tableView.setEmptyView(title: "Fetching posts...", message: "")
            } else {
                tableView.setEmptyView(title: "You haven't posted anything yet.", message: "Your posts will be in here.")
            }
        } else {
            tableView.restore()
        }
        
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let post = posts[indexPath.row]

        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        cell.textLabel?.text = post.title
        
        cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 13.0)
        cell.detailTextLabel?.text = "last updated on \(Utilities.getFormattedDateString(post.lastUpdated!))"

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let post = posts[indexPath.row]
            db.collection("posts").document(post.id!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    self.posts.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewupdatepost" {
            let row = self.tableView.indexPathForSelectedRow?.row
            
            if let vdc = segue.destination as? PostCRUViewController {
                vdc.post = posts[row ?? 0]
            }
        }
    }

}
