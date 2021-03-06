//
//  SettingsViewController.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 01/03/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FirebaseDatabase


class SettingsViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 3
        }else { return 2 }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = UITableViewCell()
        
        if indexPath.row == 0 && indexPath.section == 0 {
            
            cell.textLabel?.text = "Set goal"
        }
        
        if indexPath.row == 0 && indexPath.section == 1 {
        
            cell.textLabel?.text = "Log out"
            
        }
        
        if indexPath.row == 1 && indexPath.section == 1 {
            
            cell.textLabel?.text = "Delete account"
        }
        
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 && indexPath.section == 1 {
        
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            FBSDKLoginManager().logOut()
            goToAuthenticationViewController()
        }
        
        if indexPath.row == 1 && indexPath.section == 1 {
        
            let user = FIRAuth.auth()?.currentUser
            
            showAlertController(title: "Are you sure?", message: "This action is permanent", action: {
                
                self.ref.child("users").child((user?.uid)!).removeValue(completionBlock: { (error, reference) in
                    if error != nil{
                    
                        print(error)
                    }else{
                        
                        print("Successfully removed user")
                        print(reference)
                    
                    }
                })
                
                user?.delete { error in
                    if let error = error {
                        // An error happened.
                    } else {
                        // Account deleted.
                        print("Account deleted")
                        self.goToAuthenticationViewController()
                    }
                }
            })
            
            
        
        }
        
        if indexPath.row == 0 && indexPath.section == 0 {
            
            //REQUEST AND CHANGE GOAL FOR CURRENT USER
            requestGoalValue(completionHandler: { (goal) in
                
                self.changeGoal(goal: goal)
                
            })
        }
        
    }
    
    func showAlertController(title:String, message: String, action: @escaping () -> ()){
        
        let alertController = UIAlertController(title: title, message:message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            action()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    
    
    }
    
    func goToAuthenticationViewController(){
    
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let loginView: Authenticate = storyboard.instantiateViewController(withIdentifier: "AUTH") as! Authenticate
        UIApplication.shared.keyWindow?.rootViewController = loginView
    }
    
    func requestGoalValue(completionHandler:@escaping (Float) -> ()){
    
        ref.child("users").child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let goal = value?["goal"] as? Float ?? 0
           
            completionHandler(goal)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    
    }
    
    func changeGoal(goal:Float){
        
        let alertController = UIAlertController(title: "Set your new goal", message: "Set a new value for your goal", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                
                let NSStringValue = field.text! as NSString
                let floatValue = NSStringValue.floatValue
                
                self.ref.child("users").child(userid).child("goal").setValue(floatValue)
                
            } else {
                // user did not fill field
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "goal"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)

    
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
