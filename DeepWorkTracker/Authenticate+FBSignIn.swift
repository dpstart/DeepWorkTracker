//
//  Authenticate+FBSignIn.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 01/03/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import FBSDKLoginKit
import FirebaseAuth

extension Authenticate {
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
        print("User logged out")
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
                let handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
                    
                    if(user != nil){
                        self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if snapshot.hasChild((user?.uid)!){
                                
                                print("User already registered")
                                
                            }else{
                                
                                print("User not registered")
                                isNewUser = true
                                self.ref.child("users").child((user?.uid)!).setValue(["username" : email , "hours" : 0, "this_month":0, "this_week":0, "today":0, "goal" : 0, "weekly" : [0,0,0,0,0,0,0], "goal" : 0])
                            }
                            
                            userid = (user?.uid)!
                            
                        })
                        
                        /* userid = (user?.uid)!
                         self.ref.child("users").child((user?.uid)!).setValue(["username" : email ?? "", "hours" : 0, "this_month":0, "this_week":0, "today":0, "goal" : 0, "weekly" : [0,0,0,0,0,0,0]])*/
                        
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav")
                        self.present(vc!, animated: true, completion: nil)
                    }
                }
                
                
            }
        })
        
        
    }


}
