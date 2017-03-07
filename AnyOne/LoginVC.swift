//
//  LoginVC.swift
//  AnyOne
//
//  Created by Samarth Paboowal on 10/12/16.
//  Copyright © 2016 Junkie Labs. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let inputsContainerView = UIView()
    let profileImageView = UIImageView()
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let loginRegisterButton = UIButton(type: .system)
    let loginRegisterSegmentedController = UISegmentedControl(items: ["Login", "Register"])
    let nameSeparatorView = UIView()
    
    var inputContainerHeightAnchor: NSLayoutConstraint?
    var nameHeightAnchor: NSLayoutConstraint?
    var emailHeightAnchor: NSLayoutConstraint?
    var passwordHeightAnchor: NSLayoutConstraint?
    var nameSeparatorHeightAnchor: NSLayoutConstraint?
    var messgesVC = MessagesVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Changing Views background color
        view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1.0)
        
        setupUI()
        
    }
    
    // Changing Status Bar Color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func setupUI() {
        
        // White Container View
        inputsContainerView.backgroundColor = UIColor.white
        inputsContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputsContainerView.layer.cornerRadius = 5
        inputsContainerView.layer.masksToBounds = true
        view.addSubview(inputsContainerView)
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerHeightAnchor?.isActive = true
        
        // Login Register Segmented Controller
        loginRegisterSegmentedController.tintColor = UIColor.white
        loginRegisterSegmentedController.translatesAutoresizingMaskIntoConstraints = false
        loginRegisterSegmentedController.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        loginRegisterSegmentedController.selectedSegmentIndex = 1
        view.addSubview(loginRegisterSegmentedController)
        loginRegisterSegmentedController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedController.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedController.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedController.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Top Profile Image View
        profileImageView.image = UIImage(named: "profile")
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedController.topAnchor, constant: -12).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImage)))
        
        // Name Text Field
        nameTextField.placeholder = "Name"
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        inputsContainerView.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameHeightAnchor?.isActive = true
        
        // Horizontal Border
        nameSeparatorView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        nameSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        inputsContainerView.addSubview(nameSeparatorView)
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorHeightAnchor = nameSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        nameSeparatorHeightAnchor?.isActive = true
        
        // Email Text Field
        emailTextField.placeholder = "Email address"
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        inputsContainerView.addSubview(emailTextField)
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailHeightAnchor?.isActive = true
        
        // Horizontal Border
        let emailSeparatorView = UIView()
        emailSeparatorView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        emailSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        inputsContainerView.addSubview(emailSeparatorView)
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Password Text Field
        passwordTextField.placeholder = "Password"
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.isSecureTextEntry = true
        inputsContainerView.addSubview(passwordTextField)
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordHeightAnchor?.isActive = true
        
        // Login Register Button
        loginRegisterButton.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 1.0)
        loginRegisterButton.setTitle("Register", for: .normal)
        loginRegisterButton.setTitleColor(UIColor.white, for: .normal)
        loginRegisterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginRegisterButton.translatesAutoresizingMaskIntoConstraints = false
        loginRegisterButton.layer.cornerRadius = 5
        loginRegisterButton.layer.masksToBounds = true
        view.addSubview(loginRegisterButton)
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginRegisterButton.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
    }
    
    func handleLoginRegister() {
        
        if loginRegisterSegmentedController.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
            (user, error) in
            
            if let error = error as? NSError {
                
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Go Back", style: UIAlertActionStyle.default, handler: nil )
                alertController.addAction(action)
                
                self.present(alertController, animated: true, completion: nil)
                
                self.nameTextField.text = ""
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                
                return
                
            }
            
            self.messgesVC.fetchUserNameAndDisplayNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else { return }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {
            (user, error) in
          
            if let error = error as? NSError {
                
                let alertController = UIAlertController(title: "Registration Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Go Back", style: UIAlertActionStyle.default, handler: nil )
                alertController.addAction(action)
                
                self.present(alertController, animated: true, completion: nil)
                
                self.nameTextField.text = ""
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                
                return

            }
            
            guard let uid = user?.uid else { return }
            
            // Upload Image to Firebase Storage
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("Profile_Images").child("\(imageName).png")
            
            if let profileImage = self.profileImageView.image {
                if let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
                storageRef.put(uploadData, metadata: nil, completion: {
                    (metadata, error) in
                    
                    if let uploadError = error as? NSError {
                        
                        let alertController1 = UIAlertController(title: "Upload Error", message: uploadError.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let action1 = UIAlertAction(title: "Go Back", style: UIAlertActionStyle.default, handler: nil )
                        alertController1.addAction(action1)
                    }
                    
                    if let imageURL = metadata?.downloadURL()?.absoluteString {
                        
                        let value = ["name": name,
                                     "email": email,
                                     "profileImageURL": imageURL]
                        
                        self.updateDatabase(uid: uid, values: value)
                    }
                    
                })
            }
            }
            
        })
    }
    
    func updateDatabase(uid: String, values: [String:Any]) {
        
        let ref = FIRDatabase.database().reference(fromURL: "https://anyone-ac12e.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: {
            (errUpdate, ref) in
            
            if errUpdate != nil {
                print(errUpdate!.localizedDescription)
                return
            }
        })
        
        self.messgesVC.fetchUserNameAndDisplayNavBarTitle()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleProfileImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var pickedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
          
            pickedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            pickedImageFromPicker = originalImage
        }
        
        if let pickedImage = pickedImageFromPicker {
            
            profileImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func handleLoginRegisterChange() {
        
        let title = loginRegisterSegmentedController.titleForSegment(at: loginRegisterSegmentedController.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        inputContainerHeightAnchor?.constant = loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 100 : 150
        
        nameHeightAnchor?.isActive = false
        nameHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextField.placeholder = loginRegisterSegmentedController.selectedSegmentIndex == 0 ? "" : "Name"
        nameHeightAnchor?.isActive = true
        
        emailHeightAnchor?.isActive = false
        emailHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailHeightAnchor?.isActive = true
        
        passwordHeightAnchor?.isActive = false
        passwordHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordHeightAnchor?.isActive = true
    }
    
}
