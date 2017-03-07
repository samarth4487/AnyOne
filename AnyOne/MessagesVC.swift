//
//  ViewController.swift
//  AnyOne
//
//  Created by Samarth Paboowal on 10/12/16.
//  Copyright © 2016 Junkie Labs. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: UITableViewController {

    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding Left Navigation Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(handleNewMessage))
        
        navigationItem.title = ""
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "cell")
        
        //observeMessages()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
    }
    
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: {
            ( snapshot ) in
            
            let userID = snapshot.key
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: {
                ( snapshot ) in
                
                let messageID = snapshot.key
                
                let messageRef = FIRDatabase.database().reference().child("messages").child(messageID)
                messageRef.observeSingleEvent(of: .value, with: {
                    ( snapshot ) in
                    
                    if let dict = snapshot.value as? [String:Any] {
                        
                        let message = Message()
                        message.fromId = dict["fromID"] as! String!
                        message.toId = dict["toId"] as! String!
                        message.message = dict["message"] as! String!
                        // This was storing all the messages
                        //self.messages.append(message)
                        
                        if let chatPartnerID = message.chatPartnerId() {
                            // Creating a dict which maps from user to messge (latest msg only)
                            self.messagesDictionary[chatPartnerID] = message
                            // This is storing only the latest message from every user
                            self.messages = Array(self.messagesDictionary.values)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }, withCancel: nil)
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let message = messages[indexPath.row]
        
        if let chatPartnerID = message.chatPartnerId() {
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerID).removeValue(completionBlock: { (error, ref) in
                
                if let error = error as? NSError {
                    
                    print(error.localizedDescription)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerID)
                self.messages.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        
        let chatPartnerId: String?
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            chatPartnerId = message.toId
        } else {
            chatPartnerId = message.fromId
        }
        
        if let ID = chatPartnerId {
            let ref = FIRDatabase.database().reference().child("users").child(ID)
            ref.observeSingleEvent(of: .value, with: {
                ( snapshot ) in
                
                if let dict = snapshot.value as? [String:Any] {
                    cell.textLabel?.text = dict["name"] as? String
                    
                    if let profileImageURL = dict["profileImageURL"] as? String {
                        cell.profileImageView.downloadImageAndCache(imageURL: profileImageURL as NSString)
                    }
                }
            }, withCancel: nil)
        }
        
        cell.detailTextLabel?.text = message.message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        let chatPartnerID: String?
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            chatPartnerID = message.toId
        } else {
            chatPartnerID = message.fromId
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerID!)
        ref.observeSingleEvent(of: .value, with: {
            ( snapshot ) in
            
            if let dic = snapshot.value as? [String:Any] {
                let user = User()
                user.id = snapshot.key
                user.email = dic["email"] as! String!
                user.name = dic["name"] as! String!
                user.profileImageURL = dic["profileImageURL"] as! String!
                
                self.showChatLogControllerWithUser(user: user)
                
            }
            
        }, withCancel: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            
            fetchUserNameAndDisplayNavBarTitle()
        }
    }
    
    func fetchUserNameAndDisplayNavBarTitle() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if let dict = snapshot.value as? [String: Any] {
                
                self.navigationItem.title = dict["name"] as? String
            }
            
        }, withCancel: nil)
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
    }
    
    func showChatLogControllerWithUser(user: User) {
        
        let chatLogVC = ChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.user = user
        navigationController?.pushViewController(chatLogVC, animated: true)
        
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        let loginVC = LoginVC()
        loginVC.messgesVC = self
        present(loginVC, animated: true, completion: nil)
    }
    
    func handleNewMessage() {
        
        let newMessageVC = NewMessagesVC()
        newMessageVC.messagesVC = self
        let navigation = UINavigationController(rootViewController: newMessageVC)
        
        present(navigation, animated: true, completion: nil)
    }
}

