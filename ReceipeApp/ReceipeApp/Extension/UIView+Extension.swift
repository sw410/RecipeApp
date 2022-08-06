//
//  UIView+Extension.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import Foundation
import UIKit

extension UIView {
    
    func dropShadow(scale: Bool = true, offSet: CGSize = CGSize(width: 3, height: 3)) {
        layer.masksToBounds = false
        layer.shadowColor = R.color.black()!.withAlphaComponent(0.3).cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = offSet
        layer.shadowRadius = 4
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
