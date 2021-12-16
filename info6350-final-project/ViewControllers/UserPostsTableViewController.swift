//
//  UserPostsTableViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/14/21.
//

import UIKit
import FirebaseAuth

class UserPostsTableViewController: UITableViewController {
    
    let ds = DataStore.shared
    
    var posts:[Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationItem.hidesBackButton = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout", style: .plain, target: self, action: #selector(doLogout)
        )
    }
    
    @objc private func doLogout() {
        let alert = UIAlertController(title: "Logout", message: "Confirm?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            do {
                try Auth.auth().signOut()
                self.navigationController?.popViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count = posts.count
        
        if count == 0 {
            tableView.setEmptyView(title: "You haven't posted anything yet.", message: "Your posts will be in here.")
        } else {
            tableView.restore()
        }
        
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let post = posts[indexPath.row]

        cell.textLabel?.text = post.title!

        return cell
    }
    
    func refreshData() {
        posts = ds.getPostsByAuthUser()
        tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ds.deletePost(posts[indexPath.row])
            refreshData()
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
