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
    var dailyHoursFrame = UILabel()
    
    var add30 = UIButton()
    
    var goalLabel = UILabel()
    
    struct stats {
        
        var hours:Int?
        var monthly:Int?
        var weekly:Int?
        var daily:Int?
        var goal:Int?
    }
 
    var statistics:stats?
    
    func add30Minutes(){
        print("Adding time...")
    }
    
    func showUI(){
    
        let backgroundView = UIView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2)
        backgroundView.backgroundColor =  UIColor(red: 207/255, green: 216/255, blue: 220/255, alpha: 0.5)
        view.addSubview(backgroundView)
        
        let totHoursFrame = CGRect(x: 20, y: 40, width: 100, height: 35)
        totHoursLabel = CustomLabel(frame: totHoursFrame, color: UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1), text: "TOTAL")
        backgroundView.addSubview(totHoursLabel)
        
        let monthlyHoursFrame = CGRect(x: 20, y: totHoursLabel.frame.maxY+20, width: 100, height: 35)
        monthlyHoursLabel = CustomLabel(frame: monthlyHoursFrame, color: UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1), text: "MONTHLY")
        backgroundView.addSubview(monthlyHoursLabel)
        
        let weeklyHoursFrame = CGRect(x: 20, y: monthlyHoursLabel.frame.maxY+20, width: 100, height: 35)
        weeklyHoursLabel = CustomLabel(frame: weeklyHoursFrame, color: UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1), text: "WEEKLY")
        backgroundView.addSubview(weeklyHoursLabel)
        
        let dailyHoursFrame = CGRect(x: 20, y: weeklyHoursLabel.frame.maxY + 38, width: 170, height: 50)
        let dailyHoursLabel = CustomLabel(frame: dailyHoursFrame, color: UIColor.green, text: "TODAY")
        backgroundView.addSubview(dailyHoursLabel)
        
        
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
        
        let dailyNumber = UILabel()
        dailyNumber.frame = CGRect(x: dailyHoursLabel.frame.maxX + 30, y: dailyHoursLabel.frame.minY, width: 50, height: 50)
        dailyNumber.text = String(self.statistics!.daily!)
        dailyNumber.font = UIFont.boldSystemFont(ofSize: 22)
        backgroundView.addSubview(dailyNumber)
        
        let progView = UIProgressView()
        progView.frame = CGRect(x: 20, y: view.frame.maxY - self.view.frame.height/4 - 20, width:view.frame.width - 40 , height: 20)
        progView.progressTintColor = UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1)
        view.addSubview(progView)
        progView.progress = Float(self.statistics!.daily!) / Float(self.statistics!.goal!)
        
        add30.frame = CGRect(x: 0, y: 0, width: 170, height: 50)
        add30.center = CGPoint(x: view.center.x, y: progView.frame.maxY + 50)
        add30.layer.cornerRadius = add30.frame.height/2
        add30.clipsToBounds = true
        add30.setTitle("+30 minutes", for: .normal)
        add30.backgroundColor = .green
        add30.addTarget(self, action: #selector(add30Minutes), for: .touchUpInside)
        
        view.addSubview(add30)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //let username = value?["username"] as? String ?? ""
            let hours = value?["hours"] as? Int ?? 0
            let monthly = value?["this_month"] as? Int ?? 0
            let weekly = value?["this_week"] as? Int ?? 0
            let daily = value?["today"] as? Int ?? 0
            let goal = value?["goal"] as? Int ?? 0
            
            self.statistics = stats(hours: hours, monthly: monthly, weekly: weekly, daily: daily, goal: goal)
            
            
            // ...
            
            self.showUI()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }



}
