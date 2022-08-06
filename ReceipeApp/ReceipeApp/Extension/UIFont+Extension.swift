import UIKit

extension UIFont {
    
    enum FontNameType: String {
        case PoppinsMedium = "Poppins-Medium"
        case PoppinsRegular = "Poppins-Regular"
        case PoppinsSemiBold = "Poppins-SemiBold"
        case PoppinsBold = "Poppins-Bold"
    }
    
    class func fontNameAndSize(name: FontNameType, size: CGFloat) -> UIFont {
        return UIFont(name: name.rawValue, size: size)!
    }
    
    class func fontNameAndSizeWithDevice(name: FontNameType, size: CGFloat, additionalDeduct: CGFloat = 0) -> UIFont {
        let fontSize = size
        return UIFont(name: name.rawValue, size: fontSize)!
    }
    
}

