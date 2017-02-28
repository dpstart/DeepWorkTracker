//
//  StatsViewController.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 28/02/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseDatabase

class StatsViewController: UIViewController {
    
    var chart = LineChartView()
    
    var ref: FIRDatabaseReference!
    
    var workData = [Double]()
    
    func setChart() {
        chart.noDataText = "You need to provide data for the chart."
        chart.chartDescription?.enabled = false
        chart.drawGridBackgroundEnabled = false
        chart.legend.enabled = false
        
        let xAxis = chart.xAxis
        xAxis.drawLabelsEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        
        let leftAxis = chart.leftAxis
        leftAxis.drawLabelsEnabled = false
        //leftAxis.drawAxisLineEnabled = false
        leftAxis.axisLineColor = .white
        leftAxis.drawGridLinesEnabled = false
        leftAxis.axisMinimum = 0.0
        
        let rightAxis = chart.rightAxis
        rightAxis.drawLabelsEnabled = false
        rightAxis.gridColor = .white
        rightAxis.axisLineColor = .white
        rightAxis.axisMinimum = 0.0
        //rightAxis.drawAxisLineEnabled = false
        //rightAxis.drawGridLinesEnabled = false
     
    
        
        chart.setScaleEnabled(false)
        
         let dataSet = LineChartDataSet()
        
        var i:Double = 0;
        for elem in workData{
        
            print(elem)
            let dataEntry = ChartDataEntry(x: i, y: elem)
            dataSet.addEntry(dataEntry)
            i += 1
        }
       
      
      //  dataSet = LineChartDataSet(values: [dataEntry, dataEntry2], label: "stuff")
        dataSet.setColor(.red)
        dataSet.setCircleColor(.red)
        dataSet.drawValuesEnabled = false
        chart.data = LineChartData(dataSets: [dataSet])
        
        chart.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInSine)
        chart.backgroundColor = UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:0.5)
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
 
        chart.frame = CGRect(x: 0, y: 0, width: view.frame.width-40, height: 300)
        chart.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(chart)
        
        ref = FIRDatabase.database().reference()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //let username = value?["username"] as? String ?? ""
            /*let hours = value?["hours"] as? Int ?? 0
            let monthly = value?["this_month"] as? Int ?? 0
            let weekly = value?["this_week"] as? Int ?? 0
            let daily = value?["today"] as? Int ?? 0
            let goal = value?["goal"] as? Int ?? 0*/
            
            let week = value?["weekly"] as? NSArray ?? NSArray()
            
            for elem in week {
                self.workData.append(elem as! Double)
            }
            
           self.setChart()
        }) { (error) in
            print(error.localizedDescription)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
