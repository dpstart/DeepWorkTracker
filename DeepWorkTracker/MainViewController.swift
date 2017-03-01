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
    
    var showed = false
    
    var add30 = UIButton()
    
    var goalLabel = UILabel()
    
    var totalNumber = UILabel()
    var monthlyNumber = UILabel()
    var weeklyNumber = UILabel()
    var dailyNumber = UILabel()
    
    struct stats {
        
        var hours:Float?
        var monthly:Float?
        var weekly:Float?
        var daily:Float?
        var goal:Float?
    }
 
    var statistics:stats?
    
    func readCurrentDay( completionHandler: @escaping (Int) -> ()){
        
        //Reads current week day from database
        ref.child("data").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let currentDayInt = value?["current_day"] as? Int ?? 0
            
            let currentDay = "\(currentDayInt)"
            
            completionHandler(currentDayInt)
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    
    }
    
    func add30Minutes(){
        
        readCurrentDay { (currentDay) in
            
            
            self.ref.child("users").child(userid).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                // Set value and report transaction success
                
                
                var data = currentData.value as? [String : Any] ?? [:]
                
                var today = data["today"] as? Float ?? 0
                var week =  data["this_week"] as? Float ?? 0
                var month = data["this_month"] as? Float ?? 0
                var tot = data["hours"] as? Float ?? 0
                
                var weekDays = data["weekly"] as? [Float] ?? []
                var todayValue = weekDays[currentDay]
                todayValue += 1
                weekDays[currentDay] = todayValue
                
                print(weekDays)
                
               /* if var value = todayValue{
                    value += 0.5
                    weekDays[currentDay] = value
                    
                    print("Weekdays: \(weekDays)")
                }*/
                
                
                
                today += 0.5
                week += 0.5
                month += 0.5
                tot += 0.5
                
                data["today"] = today as Any?
                data["this_week"] = week as Any?
                data["this_month"] = month as Any?
                data["hours"] = tot as Any?
                data["weekly"] = weekDays as [Any]
                
                currentData.value = data
                
                return FIRTransactionResult.success(withValue: currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
        }
        
       
    }
    
    func showUI(){
    
        /*let backgroundView = UIView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2)
        backgroundView.backgroundColor =  UIColor(red: 207/255, green: 216/255, blue: 220/255, alpha: 0.5)
        view.addSubview(backgroundView)*/
        
        if showed == false {
        
            let backgroundImageView = UIImageView()
            backgroundImageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2 + view.frame.height/5)
            backgroundImageView.image = #imageLiteral(resourceName: "login-background")
            backgroundImageView.layer.shadowColor = UIColor.black.cgColor
            backgroundImageView.layer.shadowOpacity = 1
            backgroundImageView.layer.shadowOffset = CGSize.zero
            backgroundImageView.layer.shadowRadius = 10
            view.addSubview(backgroundImageView)
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = backgroundImageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundImageView.addSubview(blurEffectView)
            
            let totHoursFrame = CGRect(x: 0, y: 0, width: 100, height: 35)
            totHoursLabel = CustomLabel(frame: totHoursFrame, color: UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1), text: "TOTAL")
            backgroundImageView.addSubview(totHoursLabel)
            
            totHoursLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 40, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: totHoursFrame.width, heightConstant: totHoursFrame.height)
            
            let monthlyHoursFrame = CGRect(x: 0, y: 0, width: 100, height: 35)
            monthlyHoursLabel = CustomLabel(frame: monthlyHoursFrame, color: UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1), text: "MONTHLY")
            backgroundImageView.addSubview(monthlyHoursLabel)
            monthlyHoursLabel.anchor(totHoursLabel.bottomAnchor, left: totHoursLabel.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: monthlyHoursFrame.width, heightConstant: monthlyHoursFrame.height)
            
            let weeklyHoursFrame = CGRect(x: 0, y: 0, width: 100, height: 35)
            weeklyHoursLabel = CustomLabel(frame: weeklyHoursFrame, color: UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1), text: "WEEKLY")
            backgroundImageView.addSubview(weeklyHoursLabel)
            weeklyHoursLabel.anchor(monthlyHoursLabel.bottomAnchor, left: monthlyHoursLabel.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: weeklyHoursLabel.frame.width, heightConstant: weeklyHoursLabel.frame.height)
            
            let dailyHoursFrame = CGRect(x: 0, y: 0, width: 170, height: 50)
            let dailyHoursLabel = CustomLabel(frame: dailyHoursFrame, color: UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1), text: "TODAY")
            backgroundImageView.addSubview(dailyHoursLabel)
            dailyHoursLabel.anchor(weeklyHoursLabel.bottomAnchor, left: weeklyHoursLabel.leftAnchor, bottom: nil, right: nil, topConstant: 38, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: dailyHoursLabel.frame.width, heightConstant: dailyHoursLabel.frame.height)
            
            
            totalNumber = UILabel()
            totalNumber.font = UIFont.boldSystemFont(ofSize: 20)
            totalNumber.textColor = .white
            backgroundImageView.addSubview(totalNumber)
            totalNumber.anchor(totHoursLabel.topAnchor, left: totHoursLabel.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 30)
            
            monthlyNumber = UILabel()
            monthlyNumber.font = UIFont.boldSystemFont(ofSize: 20)
            monthlyNumber.textColor = .white
            backgroundImageView.addSubview(monthlyNumber)
            monthlyNumber.anchor(monthlyHoursLabel.topAnchor, left: monthlyHoursLabel.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 30)
            
            weeklyNumber = UILabel()
            weeklyNumber.font =  UIFont.boldSystemFont(ofSize: 20)
            weeklyNumber.textColor = .white
            backgroundImageView.addSubview(weeklyNumber)
            weeklyNumber.anchor(weeklyHoursLabel.topAnchor, left: weeklyHoursLabel.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 30)
            
            dailyNumber = UILabel()
            dailyNumber.font = UIFont.boldSystemFont(ofSize: 22)
            dailyNumber.textColor = .white
            backgroundImageView.addSubview(dailyNumber)
            dailyNumber.anchor(dailyHoursLabel.topAnchor, left: dailyHoursLabel.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 30, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
            
            let progView = UIProgressView()
            //progView.frame = CGRect(x: 20, y: view.frame.maxY - self.view.frame.height/4 - 20, width:view.frame.width - 40 , height: 20)
            progView.progressTintColor = UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1)
            backgroundImageView.addSubview(progView)
            progView.anchor(dailyHoursLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 70, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
            progView.progress = Float(self.statistics!.daily!) / Float(self.statistics!.goal!)
            
            //add30.frame = CGRect(x: 0, y: 0, width: 170, height: 50)
            //add30.center = CGPoint(x: view.center.x, y: progView.frame.maxY + 50)
            
            add30.setTitle("+30 minutes", for: .normal)
            add30.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
            add30.addTarget(self, action: #selector(add30Minutes), for: .touchUpInside)
            
            view.addSubview(add30)
            add30.anchor(backgroundImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 40, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 50)
            add30.layer.cornerRadius = 25
            add30.clipsToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observe(.value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //let username = value?["username"] as? String ?? ""
            let hours = value?["hours"] as? Float ?? 0
            let monthly = value?["this_month"] as? Float ?? 0
            let weekly = value?["this_week"] as? Float ?? 0
            let daily = value?["today"] as? Float ?? 0
            let goal = value?["goal"] as? Float ?? 0
            
            self.statistics = stats(hours: hours, monthly: monthly, weekly: weekly, daily: daily, goal: goal)
            
            
            // ...
            
            self.showUI()
            self.showed = true
            self.totalNumber.text =  String(self.statistics!.hours!)
            self.monthlyNumber.text = String(self.statistics!.monthly!)
            self.weeklyNumber.text = String(self.statistics!.weekly!)
            self.dailyNumber.text = String(self.statistics!.daily!)
        })
        
        
    }



}
