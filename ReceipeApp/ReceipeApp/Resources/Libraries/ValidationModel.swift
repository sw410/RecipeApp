//
//  ValidationModel.swift
//  AIGain
//
//  Created by Kenneth Lee on 10/09/2019.
//  Copyright © 2019 FPLE. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum ValidationStatus {
    case None
    case Error
    case Success
    
    func statusColor() -> UIColor {
        switch self {
        case .Error:
            return R.color.carnation()!
        case .Success:
            return R.color.green()!
        default:
            return .clear
        }
    }
    
}

struct ValidationModel {
    var message: String = ""
    var status: ValidationStatus = .None
}

class ValidationHelper {
    
    //If result is empty, there is no error
    static func validate(validations: [ValidationModel]) -> Bool {
        let result = validations.filter { $0.status == .Error }
        return result.count == 0
    }
    
    static func bindStatus(status: Bool, message: String?) -> ValidationModel {
        return ValidationModel(message: status ? "" : message ?? "", status: status ? ValidationStatus.Success : ValidationStatus.Error)
    }
    
}
