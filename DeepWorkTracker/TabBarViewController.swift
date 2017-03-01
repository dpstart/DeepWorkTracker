//
//  TabBarViewController.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 01/03/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        tabBar.backgroundColor = UIColor(red:0/255, green: 150/255, blue: 136/255, alpha:1)
        
        tabBar.layer.borderWidth = 0.50
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.clipsToBounds = true
        
        tabBar.barTintColor = .white
        
        
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
