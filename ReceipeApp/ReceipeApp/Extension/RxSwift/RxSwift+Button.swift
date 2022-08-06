import Foundation
import RxCocoa
import RxSwift

private var ButtonIndicator   = "KJFButtonIndicator"
private var ButtonCurrentText = "KJFButtonCurrentText"

public struct ButtonTimer {
//    let title : String
    let title : NSAttributedString
    let show: Bool
    var originalTitle: String
}

extension Reactive where Base: UIButton {
    //是否秀菊花
    public var isShowIndicator: Binder<Bool>{
        return Binder(self.base, binding: { btn, active in
            if active{
                objc_setAssociatedObject(btn, &ButtonCurrentText, btn.currentTitle, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                btn.setTitle("", for: .normal)
                btn.whiteIndicator.startAnimating()
                btn.isUserInteractionEnabled = false
            }
            else{
                btn.whiteIndicator.stopAnimating()
                if let title = objc_getAssociatedObject(btn, &ButtonCurrentText) as? String{
                    btn.setTitle(title, for: .normal)
                }
                btn.isUserInteractionEnabled = true
            }
        })
    }
    
    public var isShowGrayIndicator: Binder<Bool>{
        return Binder(self.base, binding: { btn, active in
            if active{
                objc_setAssociatedObject(btn, &ButtonCurrentText, btn.currentTitle, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                btn.setTitle("", for: .normal)
                btn.grayIndicator.startAnimating()
                btn.isUserInteractionEnabled = false
            }
            else{
                btn.grayIndicator.stopAnimating()
                if let title = objc_getAssociatedObject(btn, &ButtonCurrentText) as? String{
                    btn.setTitle(title, for: .normal)
                }
                btn.isUserInteractionEnabled = true
            }
        })
    }
    
    public var isShowTimer: Binder<ButtonTimer>{
        return Binder(self.base, binding: { btn, model in
            if model.show {
//                objc_setAssociatedObject(btn, &ButtonCurrentText, btn.currentTitle, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                btn.setTitle(model.title, for: .normal)
                btn.setTitle(nil, for: .normal)
                btn.setAttributedTitle(model.title, for: .normal)
                btn.isUserInteractionEnabled = false
            } else {
//                if let title = objc_getAssociatedObject(btn, &ButtonCurrentText) as? String{
//                    btn.setTitle(title, for: .normal)
//                }
                
                btn.setAttributedTitle(nil, for: .normal)
                btn.setTitle(model.originalTitle, for: .normal)
                btn.isUserInteractionEnabled = true
            }
        })
    }

    
}




public extension UIButton {
    var whiteIndicator : UIActivityIndicatorView{
        get {
            var indicator = objc_getAssociatedObject(self, &ButtonIndicator)
                as? UIActivityIndicatorView
            if indicator == nil{
                indicator = UIActivityIndicatorView(style: .gray)
//                indicator!.center = CGPoint(x: self.bounds.width / 2,
//                                            y: self.bounds.height / 2)
                self.addSubview(indicator!)
                indicator!.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview()
                }
//                indicator?.startAnimating()
            }
            self.whiteIndicator = indicator!
            return indicator!
        }
        set{
            objc_setAssociatedObject(self, &ButtonIndicator, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var grayIndicator : UIActivityIndicatorView{
        get {
            var indicator = objc_getAssociatedObject(self, &ButtonIndicator)
                as? UIActivityIndicatorView
            if indicator == nil{
                indicator = UIActivityIndicatorView(style: .gray)
//                indicator!.center = CGPoint(x: self.bounds.width / 2,
//                                            y: self.bounds.height / 2)
                self.addSubview(indicator!)
                indicator!.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview()
                }
//                indicator?.startAnimating()
            }
            self.whiteIndicator = indicator!
            return indicator!
        }
        set{
            objc_setAssociatedObject(self, &ButtonIndicator, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
