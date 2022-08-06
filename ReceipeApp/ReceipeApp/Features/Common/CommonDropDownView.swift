//
//  CommonDropDownView.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import UIKit
import IBAnimatable
import RxSwift
import RxCocoa

class CommonDropDownView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var containerView: AnimatableView!
    @IBOutlet weak var textField: UITextField!
    
    var placeHolder: String? {
        didSet {
            guard let placeHolder = placeHolder else { return }
            self.textField.placeholder = placeHolder
        }
    }
    
    var textValue: String? {
        didSet {
            guard let textValue = textValue else { return }
            self.textField.text = textValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        self.commonInit()
    }
    
    private func commonInit() {
        guard let customView = UINib(resource: R.nib.commonDropDownView).instantiate(withOwner: self, options: nil).first as? UIView else { return }
        customView.frame = bounds
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(customView)
        
    }

}
