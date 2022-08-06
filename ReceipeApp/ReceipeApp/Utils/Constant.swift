//
//  Constant.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import Foundation
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

struct Constant {
    
    static let isFirstTimeLoad = "isFirstTimeLoad"
    
    static func setIsFirstTimeLoad(_ value: Bool) {
        UserDefaults.standard.setValue(value, forKey: self.isFirstTimeLoad)
        UserDefaults.standard.synchronize()
    }
    
    static func getIsFirstTimeLoad() -> Bool {
        let value = UserDefaults.standard.bool(forKey: self.isFirstTimeLoad)
        return value
    }
}
