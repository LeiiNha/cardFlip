//
//  TextField+Label.swift
//  CardFlip
//
//  Created by Erica Geraldes on 21/12/2018.
//  Copyright © 2018 Erica Geraldes. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    private static var _myComputedProperty = [String:UILabel]()
    
    var assignedLabel:UILabel? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UITextField._myComputedProperty[tmpAddress] ?? nil
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UITextField._myComputedProperty[tmpAddress] = newValue
        }
    }
}
