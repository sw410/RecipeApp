import Foundation
import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: ValidationLabel {
    
    var model: Binder<ValidationModel> {
        return Binder(self.base) { label, model in
            label.text = model.message
            label.textColor = model.status.statusColor()
            label.isHidden = model.status == .Success || model.status == .None ? true : model.message == ""
        }
    }
    
}
