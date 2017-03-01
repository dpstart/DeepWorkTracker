//
//  Authenticate+GoogleSignIn.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 01/03/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

extension Authenticate {
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
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
                    isNewUser = true
                    self.ref.child("users").child((user?.uid)!).setValue(["username" : user?.email, "hours" : 0, "this_month":0, "this_week":0, "today":0, "goal" : 0, "weekly" : [0,0,0,0,0,0,0]])
                }
                
                userid = (user?.uid)!
                
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

}
