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

class Authenticate: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    
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
                    self.ref.child("users").child((user?.uid)!).setValue(["username" : user?.email, "hours" : 0, "this_month":0, "this_week":0, "today":0, "goal" : 0])
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
                    self.ref.child("users").child((user?.uid)!).setValue(["username": self.username.text])
                    userid = (user?.uid)!
                    
                    
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
    

    override func viewDidLoad() {
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self

        ref = FIRDatabase.database().reference()
        //GIDSignIn.sharedInstance().signIn()
        
        
        
        let btnFrame = CGRect(x: 0, y: 0, width: 270, height: 45)
        
        let  loginBtn = Button(frame: btnFrame, text: "Log in")
        loginBtn.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
        view.addSubview(loginBtn)
        loginBtn.center = CGPoint(x: view.center.x , y:view.frame.maxY - 40 - 150)
        
        let frame = CGRect(x: 0, y: 0, width: 270, height: 45)
        
        password = TextField(frame: frame)
        view.addSubview(password)
        password.center = CGPoint(x: self.view.center.x, y: loginBtn.frame.minY - 60)
        password.isSecureTextEntry = true
        
        username = TextField(frame: frame)
        view.addSubview(username)
        username.center = CGPoint(x: self.view.center.x, y: password.frame.minY - 40)
        
        let googleAuth = GIDSignInButton()
        googleAuth.frame = CGRect(x: 0, y: 0, width: 270, height: 30)
        googleAuth.center = CGPoint(x: view.center.x, y: username.frame.minY - 35)
        //googleAuth.layer.cornerRadius = googleAuth.frame.height/2
        //googleAuth.clipsToBounds = true
        view.addSubview(googleAuth)
        
        let lbl = UILabel()
        lbl.text = "If you don't have an account, one will automatically be created for you"
        lbl.frame = CGRect(x: 5, y: loginBtn.frame.maxY + 20, width: view.frame.width - 10, height: 20)
        lbl.numberOfLines = 2
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .red
        lbl.textAlignment = .center
        //lbl.backgroundColor = .red
        view.addSubview(lbl)
   
    }
}

