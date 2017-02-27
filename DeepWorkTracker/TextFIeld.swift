//
//  TextFIeld.swift
//  DeepWorkTracker
//
//  Created by Daniele Paliotta on 27/02/17.
//  Copyright © 2017 Daniele Paliotta. All rights reserved.
//

import Foundation
import UIKit

class TextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
        font = UIFont.systemFont(ofSize: 13)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}

