//
//  ValidationLabel.swift
//  AIGain
//
//  Created by Kenneth Lee on 10/09/2019.
//  Copyright © 2019 FPLE. All rights reserved.
//

import Foundation
import UIKit

class ValidationLabel: UILabel {
    
    var model: ValidationModel? {
        didSet {
            guard let model = model else { return }
            self.text = model.message
            self.textColor = model.status.statusColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.textAlignment = .left
        self.numberOfLines = 0
        self.font = UIFont.fontNameAndSizeWithDevice(name: .PoppinsRegular, size: 12)
    }
    
}
