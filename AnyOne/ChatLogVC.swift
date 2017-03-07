//
//  ChatLogVC.swift
//  AnyOne
//
//  Created by Samarth Paboowal on 13/12/16.
//  Copyright © 2016 Junkie Labs. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogVC: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid).child((user?.id)!)
        ref.observe(.childAdded, with: {
            ( snapshot ) in
            
            let messageID = snapshot.key
            
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String:Any] {
                    let message = Message()
                    message.toId = dict["toId"] as! String!
                    message.fromId = dict["fromID"] as! String!
                    message.message = dict["message"] as! String!
                    message.imageURL = dict["imageURL"] as! String?
                    message.imageWidth = dict["imageWidth"] as! NSNumber?
                    message.imageHeight = dict["imageHeight"] as! NSNumber?
                    message.videoURL = dict["videoURL"] as! String?
                    
                    let chatPartner: String?
                    if message.fromId == FIRAuth.auth()?.currentUser?.uid {
                        chatPartner = message.toId
                    } else {
                        chatPartner = message.fromId
                    }
                    
                    if chatPartner == self.user?.id {
                        self.messages.append(message)
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                        }
                    }
                    
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)

    }
    
    let containerView = UIView()
    let sendButton = UIButton(type: .system)
    let inputTextField = UITextField()
    let uploadImageView = UIImageView()
    let seperatorLine = UIView()
    var containerViewBottomAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 66, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cell")
        
        setupInputComponents()
        
        setupKeyboardObservers()
    }
    
    func setupInputComponents() {
        
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        uploadImageView.image = UIImage(named: "imagelogo")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        inputTextField.delegate = self
        inputTextField.placeholder = "Enter message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        seperatorLine.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 220/255)
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLine)
        seperatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var pickedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            pickedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            pickedImage = originalImage
        }
        
        if let selectedImage = pickedImage {
            
            uploadImageToFirebaseStorage(image: selectedImage)
        }
        
        if let videoFile = info["UIImagePickerControllerMediaURL"] as? NSURL {
            
            uploadVideo(videoURL: videoFile)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadVideo(videoURL: NSURL) {
        
        let fileName = NSUUID().uuidString
        let uploadTask = FIRStorage.storage().reference().child("Messages_Videos").child("\(fileName).mov").putFile(videoURL as URL, metadata: nil) { (metadata, error) in
            
            if let error = error as? NSError {
                
                print(error.localizedDescription)
                return
            }
            
            let thumbnailImage: UIImage?
            
            if let uploadURL = metadata?.downloadURL()?.absoluteString {
                
                let asset = AVAsset(url: videoURL as URL)
                let assetGenerator = AVAssetImageGenerator(asset: asset)
                do {
                    let thumbnailCGImage = try assetGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
                    thumbnailImage = UIImage(cgImage: thumbnailCGImage)
                    
                } catch let err {
                    print(err)
                    thumbnailImage = nil
                }
                
                let imageName = NSUUID().uuidString
                let ref = FIRStorage.storage().reference().child("Message_Images").child("\(imageName).png")
                let uploadData = UIImageJPEGRepresentation(thumbnailImage!, 0.2)
                ref.put(uploadData!, metadata: nil) { (metadata, error) in
                    
                    if error != nil {
                        print("Failed to upload image: \(error?.localizedDescription)")
                    }
                    
                    if let imageURL = metadata!.downloadURL()?.absoluteString {
                        
                        self.sendMessageWithVideoAndImage(thumbnailImage: thumbnailImage!, uploadURL: uploadURL, imageURL: imageURL)
                    }
                }
                
            }
            
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completedBytes = snapshot.progress?.completedUnitCount {
                
                self.navigationItem.title = "\(completedBytes) bytes uploaded"
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            
            self.navigationItem.title = self.user?.name
        }
    }
    
    func sendMessageWithVideoAndImage(thumbnailImage: UIImage, uploadURL: String, imageURL: String) {
        
        let refe = FIRDatabase.database().reference().child("messages")
        let childRef = refe.childByAutoId()
        let toId = self.user?.id
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let width = thumbnailImage.size.width
        let height = thumbnailImage.size.height
        
        let values: [String: Any] = ["fromID": fromId,
                                     "toId": toId,
                                     "imageWidth": width,
                                     "imageHeight": height,
                                     "imageURL": imageURL,
                                     "videoURL": uploadURL]
        
        
        childRef.updateChildValues(values, withCompletionBlock: {
            (error, ref) in
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageID = childRef.key
            userMessagesRef.updateChildValues([messageID:1])
            
            let recepientRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
            recepientRef.updateChildValues([messageID:1])
            
        })
        
        self.inputTextField.text = ""
    }
    
    func uploadImageToFirebaseStorage(image: UIImage){
        
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("Message_Images").child("\(imageName).png")
        let uploadData = UIImageJPEGRepresentation(image, 0.2)
        ref.put(uploadData!, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print("Failed to upload image: \(error?.localizedDescription)")
            }
            
            if let imageURL = metadata!.downloadURL()?.absoluteString {
                
                self.sendMessageWithImage(imageUrl: imageURL, image: image)
            }
        }
    }
    
    private func sendMessageWithImage(imageUrl: String, image: UIImage) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = FIRAuth.auth()?.currentUser?.uid
        
        let width = image.size.width
        let height = image.size.height
        
        let values: [String: Any] = ["fromID": fromId,
                          "toId": toId,
                          "imageURL": imageUrl,
                          "imageWidth": width,
                          "imageHeight": height]
        
            
        childRef.updateChildValues(values, withCompletionBlock: {
            (error, ref) in
                
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageID = childRef.key
            userMessagesRef.updateChildValues([messageID:1])
                
            let recepientRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
            recepientRef.updateChildValues([messageID:1])
                
        })
        
        inputTextField.text = ""
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillAppear(notification: NSNotification) {
        
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        containerViewBottomAnchor?.constant = -keyboardFrame.height
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        
        containerViewBottomAnchor?.constant = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].message {
            height = estimateBubbleHeight(text: text).height + 20
            
        } else if let imageWidth = messages[indexPath.item].imageWidth?.floatValue, let imageHeight = messages[indexPath.item].imageHeight?.floatValue {
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func estimateBubbleHeight(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.message
        
        if let profileImageUrl = self.user?.profileImageURL {
            cell.profileImage.downloadImageAndCache(imageURL: profileImageUrl as NSString)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.bubbleView.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1.0)
            cell.textView.textColor = UIColor.white
            cell.profileImage.isHidden = true
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            
        } else {
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.profileImage.isHidden = false
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        if let messageImageURL = message.imageURL {
            cell.messageImageView.downloadImageAndCache(imageURL: messageImageURL as NSString)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
        } else {
            cell.messageImageView.isHidden = true
        }
        
        if let msg = message.message {
            
            cell.bubbleWidthAnchor?.constant = estimateBubbleHeight(text: msg).width + 32
            cell.textView.isHidden = false

        } else if message.imageURL != nil {
            
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        if message.videoURL != nil {
            cell.playButton.isHidden = false
        } else {
            cell.playButton.isHidden = true
        }
        return cell
    }
    
    func handleSendMessage() {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = FIRAuth.auth()?.currentUser?.uid
        
        if inputTextField.text != nil {
            
            let values = ["fromID": fromId,
                          "toId": toId,
                          "message": inputTextField.text]
            
            //childRef.updateChildValues(values)
            
            childRef.updateChildValues(values, withCompletionBlock: {
                (error, ref) in
                
                let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
                let messageID = childRef.key
                userMessagesRef.updateChildValues([messageID:1])
                
                let recepientRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
                recepientRef.updateChildValues([messageID:1])
                
            })
        }
        
        inputTextField.text = ""
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSendMessage()
        return true
    }
    
}
