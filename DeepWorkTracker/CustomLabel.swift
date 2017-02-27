//
//  CustomLabel.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 27/02/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import Foundation
import UIKit

class CustomLabel : UILabel{
    
    init(frame: CGRect, color: UIColor, text : String) {
        super.init(frame: frame)
        backgroundColor = color
        textColor = .white
        self.text = text
        layer.cornerRadius = frame.height/2
        clipsToBounds = true
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
