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
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        // ...
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                // ...
                return
            }
            
            self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.hasChild((user?.uid)!){
                    
                    print("User already registered")
                    
                }else{
                    
                    print("User not registered")
                    self.ref.child("users").child((user?.uid)!).setValue(["username" : user?.email, "hours" : 0, "this_month":0, "this_week":0, "today":0, "goal" : 0, "weekly" : [0,0,0,0,0,0,0]])
                }
                
                
            })
            
            print("Signed in: \(user?.email)")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav")
            self.present(vc!, animated: true, completion: nil)
            /* let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let vc = mainStoryboard.instantiateViewController(withIdentifier: "nav")
             self.window = UIWindow(frame: UIScreen.main.bounds)
             self.window?.rootViewController = vc
             self.window?.makeKeyAndVisible()*/
            
        }
    }
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
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
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                // ...
                return
            }
            
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            
            self.getFBUserData()
            
          
            
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){}
    
    func getFBUserData() {
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name,picture.width(480).height(480)"]).start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                guard let res = result as? NSDictionary else { return }
                guard let email = res.value(forKey: "email") else { return }
                var handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
                    print("Fetched id:\(user?.uid)")
                    
                    self.ref.child("users").child((user?.uid)!).setValue(["username" : email ?? "", "hours" : 0, "this_month":0, "this_week":0, "today":0, "goal" : 0, "weekly" : [0,0,0,0,0,0,0]])
                    
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav")
                    self.present(vc!, animated: true, completion: nil)
                }
                
                
            }
        })

    
    }
   
       override func viewDidLoad() {
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self

        ref = FIRDatabase.database().reference()
        //GIDSignIn.sharedInstance().signIn()
        
        //hideKeyboardWhenTappedAround()
    
        
        let frame = CGRect(x: 0, y: 0, width: 270, height: 45)
        
        username = TextField(frame: frame)
        view.addSubview(username)
        username.center = CGPoint(x: self.view.center.x , y: view.center.y - view.frame.height/5)
        
        password = TextField(frame: frame)
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
        noticeLbl.textColor = .red
        noticeLbl.textAlignment = .center
        view.addSubview(noticeLbl)
        
        noticeLbl.anchor(loginBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width-30, heightConstant: 35)
        
        let resetPassBtn = UIButton()
        resetPassBtn.setTitle("I forgot my password", for: .normal)
        resetPassBtn.setTitleColor(.black, for: .normal)
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

