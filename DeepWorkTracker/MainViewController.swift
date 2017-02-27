//
//  MainViewController.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 27/02/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class MainViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var totHoursLabel = UILabel()
    var monthlyHoursLabel = UILabel()
    var weeklyHoursLabel = UILabel()
    
    var goalLabel = UILabel()
    
    struct stats {
        
        var hours:Int?
        var monthly:Int?
        var weekly:Int?
        var daily:Int?
    }
 
    var statistics:stats?
    
    func showUI(){
    
        let backgroundView = UIView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2)
        backgroundView.backgroundColor =  UIColor(red: 207/255, green: 216/255, blue: 220/255, alpha: 0.5)
        view.addSubview(backgroundView)
        
        let totHoursFrame = CGRect(x: 20, y: 40, width: 100, height: 35)
        totHoursLabel = CustomLabel(frame: totHoursFrame, color: UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1), text: "TOTAL")
        backgroundView.addSubview(totHoursLabel)
        
        let monthlyHoursFrame = CGRect(x: 20, y: totHoursLabel.frame.maxY+20, width: 100, height: 35)
        monthlyHoursLabel = CustomLabel(frame: monthlyHoursFrame, color: UIColor(red:21/255, green: 101/255, blue: 192/255, alpha:1), text: "MONTHLY")
        backgroundView.addSubview(monthlyHoursLabel)
        
        let weeklyHoursFrame = CGRect(x: 20, y: monthlyHoursLabel.frame.maxY+20, width: 100, height: 35)
        weeklyHoursLabel = CustomLabel(frame: weeklyHoursFrame, color:UIColor(red:67/255, green: 160/255, blue: 71/255, alpha:1), text: "WEEKLY")
        backgroundView.addSubview(weeklyHoursLabel)
        
        let totalNumber = UILabel()
        totalNumber.frame = CGRect(x: totHoursLabel.frame.maxX + 20, y: totHoursLabel.frame.minY, width: 50, height: 30)
        totalNumber.text = String(self.statistics!.hours!)
        totalNumber.font = UIFont.boldSystemFont(ofSize: 20)
        backgroundView.addSubview(totalNumber)
        
        let monthlyNumber = UILabel()
        monthlyNumber.frame = CGRect(x: monthlyHoursLabel.frame.maxX + 20, y: monthlyHoursLabel.frame.minY, width: 50, height: 30)
        monthlyNumber.text = String(self.statistics!.monthly!)
        monthlyNumber.font = UIFont.boldSystemFont(ofSize: 20)
        backgroundView.addSubview(monthlyNumber)
        
        let weeklyNumber = UILabel()
        weeklyNumber.frame = CGRect(x: weeklyHoursLabel.frame.maxX + 20, y: weeklyHoursLabel.frame.minY, width: 50, height: 30)
        weeklyNumber.text = String(self.statistics!.weekly!)
        weeklyNumber.font =  UIFont.boldSystemFont(ofSize: 20)
        backgroundView.addSubview(weeklyNumber)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let hours = value?["hours"] as? Int ?? 0
            let monthly = value?["this_month"] as? Int ?? 0
            let weekly = value?["this_week"] as? Int ?? 0
            
            self.statistics = stats(hours: hours, monthly: monthly, weekly: weekly, daily: 0)
            
            
            // ...
            
            self.showUI()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }



}
