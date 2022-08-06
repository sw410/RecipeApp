//
//  UILabel+Extension.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/6/22.
//

import Foundation
import UIKit

extension UILabel {
    
    func setLineSpacing(alignment: NSTextAlignment = .left, spacing: CGFloat? = 3, text: String?) {
        let attributedString = NSMutableAttributedString(string: text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing!
        paragraphStyle.alignment = alignment
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
    
}
