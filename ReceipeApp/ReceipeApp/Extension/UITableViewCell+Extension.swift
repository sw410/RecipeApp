//
//  UITableViewCell+Extension.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/8/22.
//

import Foundation
import UIKit

extension UITableViewCell {
    class var identifier: String { return String.className(self) }
    
    static func getNib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

extension UITableViewHeaderFooterView {
    
    class var identifier: String { return String.className(self) }

    static func getNib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}

