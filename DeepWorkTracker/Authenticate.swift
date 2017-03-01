//
//  ViewController.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 26/02/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import GoogleSignIn
import LBTAComponents
import FBSDKLoginKit


// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class Authenticate: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate {
    
    
    var username = TextField()
    var password = TextField()
    
    var ref: FIRDatabaseReference!
    
    func signup(){
        
        if username.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: username.text!, password: password.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    Username = self.username.text!
                    //self.ref.child("users").child((user?.uid)!).setValue(["username": self.username.text])
                    userid = (user?.uid)!
                    
                    self.ref.child("users").child((user?.uid)!).setValue(["username" : user?.email, "hours" : 0, "this_month":0, "this_week":0, "today":0, "goal" : 0, "weekly" : [0,0,0,0,0,0,0]])
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    
    
    }
    
    
    func authenticate(){
        
        if self.username.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: self.username.text!, password: self.password.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    Username = self.username.text!
                    userid = (user?.uid)!
                
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav")
                    self.present(vc!, animated: true, completion: nil)
                    
                    //Go to the HomeViewController if the login is sucessful
                  
                } else {
                    
                    let errorcode = FIRAuthErrorCode(rawValue: (error?._code)!)
                    
                    if(errorcode == FIRAuthErrorCode.errorCodeUserNotFound){
                        self.signup()
                        return
                    }
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func resetPassword(){
        
        let alertController = UIAlertController(title: "Email?", message: "Please input your email:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                FIRAuth.auth()?.sendPasswordReset(withEmail: field.text!) { (error) in
                    let okController = UIAlertController(title: "Check your email", message: "A link to reset your password has been sent to your email", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    okController.addAction(confirm)
                    self.present(okController, animated: true, completion: nil)
                }
            } else {
                // user did not fill field
            }
          
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    
    }
    
       
       override func viewDidLoad() {
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self

        ref = FIRDatabase.database().reference()
        
        let backgroundView = UIImageView()
        backgroundView.frame = view.frame
        backgroundView.image = #imageLiteral(resourceName: "login-background")
        view.addSubview(backgroundView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
        
        
        let frame = CGRect(x: 0, y: 0, width: 270, height: 45)
        
        var usernamePlaceholder = NSMutableAttributedString()
        let usernamePlaceholderText  = "Username"
        
        // Set the Font
        usernamePlaceholder = NSMutableAttributedString(string:usernamePlaceholderText, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 15.0)!])
        
        // Set the color
        usernamePlaceholder.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGray, range:NSRange(location:0,length: usernamePlaceholderText.characters.count))
        
        
        username = TextField(frame: frame)
        username.attributedPlaceholder = usernamePlaceholder
        view.addSubview(username)
        username.center = CGPoint(x: self.view.center.x , y: view.center.y - view.frame.height/5)
        
        var passwordPlaceholder = NSMutableAttributedString()
        let passwordPlaceholderText  = "Password"
        
        // Set the Font
        passwordPlaceholder = NSMutableAttributedString(string:passwordPlaceholderText, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 15.0)!])
        
        // Set the color
        passwordPlaceholder.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGray, range:NSRange(location:0,length: passwordPlaceholderText.characters.count))
        
        password = TextField(frame: frame)
        password.attributedPlaceholder = passwordPlaceholder
        view.addSubview(password)
        password.isSecureTextEntry = true
        
        password.anchor(username.bottomAnchor, left: username.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: password.frame.width, heightConstant: password.frame.height)

        
        let  loginBtn = Button(frame: frame, text: "Log in")
        loginBtn.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
        view.addSubview(loginBtn)
        loginBtn.anchor(password.bottomAnchor, left: password.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: loginBtn.frame.width, heightConstant: loginBtn.frame.height)
    
        let noticeLbl = UILabel()
        noticeLbl.text = "If you don't have an account,one will automatically be created for you"
        //noticeLbl.frame = CGRect(x: 5, y: loginBtn.frame.maxY + 20, width: view.frame.width - 10, height: 20)
        noticeLbl.lineBreakMode = .byWordWrapping
        noticeLbl.numberOfLines = 0
        noticeLbl.font = UIFont.systemFont(ofSize: 13)
        noticeLbl.textColor = .white
        noticeLbl.textAlignment = .center
        view.addSubview(noticeLbl)
        
        noticeLbl.anchor(loginBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width-30, heightConstant: 35)
        
        let resetPassBtn = UIButton()
        resetPassBtn.setTitle("I forgot my password", for: .normal)
        resetPassBtn.setTitleColor(.white, for: .normal)
        resetPassBtn.frame = CGRect(x: 0, y: 0, width: view.frame.width-50, height: 30)
        resetPassBtn.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        view.addSubview(resetPassBtn)
        
        resetPassBtn.anchor(noticeLbl.bottomAnchor, left: noticeLbl.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: resetPassBtn.frame.width, heightConstant: 30)
        
        let googleAuth = GIDSignInButton()
        googleAuth.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        view.addSubview(googleAuth)
   
        googleAuth.anchor(resetPassBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 30, leftConstant: 30, bottomConstant: 0, rightConstant: 0, widthConstant: googleAuth.frame.width, heightConstant: googleAuth.frame.height)
        
        let FBLoginButton = FBSDKLoginButton()
        FBLoginButton.delegate = self
        FBLoginButton.readPermissions = ["public_profile", "email"]

        view.addSubview(FBLoginButton)
        FBLoginButton.anchor(googleAuth.bottomAnchor, left: googleAuth.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: googleAuth.frame.width, heightConstant: 100)
    }
}

