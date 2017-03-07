//
//  NewMessagesVC.swift
//  AnyOne
//
//  Created by Samarth Paboowal on 10/12/16.
//  Copyright © 2016 Junkie Labs. All rights reserved.
//

import UIKit
import Firebase

class NewMessagesVC: UITableViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "cell")
        
        fetchUser()
    }
    
    func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {
            (snapshot) in
            
            let key = snapshot.key
            
            if let dict = snapshot.value as? [String: Any] {
                
                let user = User()
                user.name = dict["name"] as! String!
                user.email = dict["email"] as! String!
                user.profileImageURL = dict["profileImageURL"] as! String!
                user.id = key
                self.users.append(user)
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 76
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserCell
        
        let user = self.users[indexPath.row]
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        
        if let profileImageURL = user.profileImageURL {
            
            cell?.profileImageView.downloadImageAndCache(imageURL: profileImageURL as NSString)
            
        }
        
        return cell!
    }
    
    var messagesVC = MessagesVC()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesVC.showChatLogControllerWithUser(user: user)
        }
    }
}
