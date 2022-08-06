//
//  Date+Extension.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/6/22.
//

import Foundation
import UIKit

extension Date {
    
    func toShortDate() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormat.string(from: self)
    }
    
}
