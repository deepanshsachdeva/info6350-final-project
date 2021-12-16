//
//  DataStore.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/13/21.
//

import UIKit
import CoreData
import Foundation

class DataStore {
    static let shared = DataStore()
    
    private var nextId:Int16 = 0
    
    var authUser:User?
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init() {
        //
    }
    
    func getNextId() -> Int16 {
        nextId += 1
        return nextId
    }
    
    // MARK: post tasks
    
    func addPost(_ post: Post) {
        post.id = getNextId()
        post.createdAt = Date.now
        
        do {
            managedContext.insert(post)
            try managedContext.save()
        } catch {
            fatalError("Error saving context: \(error)")
        }
    }
    
    func deletePost(_ post: Post) {
        do {
            managedContext.delete(post)
            try managedContext.save()
        } catch {
            fatalError("Error saving context: \(error)")
        }
    }
    
    func getPosts() -> [Post] {
        var posts:[Post] = []
        
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        print("fetching posts...")
        
        do {
            posts = try (self.managedContext.fetch(fetchRequest)) as [Post]
        } catch {
            fatalError("Error retrieving posts data: \(error)")
        }
        
        print("posts data fetched")
        
        return posts
    }
    
    func getPostsByAuthUser() -> [Post] {
        var posts:[Post] = []
        
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        print("fetching posts...")
        
        do {
            posts = try (self.managedContext.fetch(fetchRequest)) as [Post]
        } catch {
            fatalError("Error retrieving posts data: \(error)")
        }
        
        print("posts data fetched")
        
        return posts.filter({$0.createdBy?.id == authUser!.id})
    }
    
    // MARK: users tasks
    
    func addUser(_ user: User) {
        do {
            managedContext.insert(user)
            try managedContext.save()
        } catch {
            fatalError("Error saving context: \(error)")
        }
    }
    
    func getUserByUID(_ uid: String) -> User? {
        var users:[User] = []
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        print("fetching users...")
        
        do {
            users = try (self.managedContext.fetch(fetchRequest)) as [User]
        } catch {
            fatalError("Error retrieving users data: \(error)")
        }
        
        print("users data fetched")
        
        return users.first(where: {$0.id == uid})
    }
    
    // MARK: common tasks
    func saveContext() {
        print("saving context...")
        
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
        }
        
        print("context saved successfully!")
    }
}
