//
//  PostsTableViewController.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/14/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostsTableViewController: UITableViewController {
    var posts:[Post] = []
    
    let db = Firestore.firestore()
    
    var isRefreshing:Bool = false

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        isRefreshing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isRefreshing = true
        
        fetchData()
    }
    
    @objc func refreshData() {
        isRefreshing = true
        
        self.posts = []
        
        tableView.reloadData()
        
        fetchData()
    }
    
    func fetchData() {
        tableView.refreshControl?.beginRefreshing()
        
        db.collection("posts").order(by: "lastUpdated", descending: true).getDocuments() { (querySnapshot, err) in
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
            
            self.tableView.refreshControl?.endRefreshing()
            self.isRefreshing = false
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = posts.count
        
        if count == 0 {
            if isRefreshing {
                tableView.setEmptyView(title: "Fetching posts...", message: "")
            } else {
                tableView.setEmptyView(title: "No posts available yet.", message: "Posts will be in here.")
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
        cell.textLabel?.text = "\(post.title) by \(post.createdByFullName)"
        
        cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 13.0)
        cell.detailTextLabel?.text = "last updated on \(Utilities.getFormattedDateString(post.lastUpdated!))"

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "postdetails" {
            let row = self.tableView.indexPathForSelectedRow?.row
            
            if let vdc = segue.destination as? PostDetailsViewController {
                vdc.post = posts[row ?? 0]
            }
        }
    }

}
