//
//  Button.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 27/02/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import Foundation
import UIKit

class Button : UIButton {
    
    init(frame: CGRect, text:String) {
        super.init(frame: frame)
        
        setTitle(text, for: .normal)
        setTitleColor(UIColor.white, for: .normal)
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
