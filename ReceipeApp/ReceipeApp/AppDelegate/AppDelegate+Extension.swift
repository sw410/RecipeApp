//
//  AppDelegate+Extension.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import Foundation
import IQKeyboardManagerSwift
import SnapKit
import RxCocoa
import RxSwift
import NSObject_Rx

extension AppDelegate {
    
    func appInitializes() {
        RecipeManager.shared.fetchReceipeList()
        
        if !Constant.getIsFirstTimeLoad() {
            RecipeManager.shared.populateDummyData()
        }
        
        
        self.keyboardManager()
        self.initController()
    }
    
    func keyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarManageBehaviour = .byPosition
    }
    
    func initController() {
        let controller = BaseNavigationController(rootViewController: ReceipeListController())
        appDelegate.window?.rootViewController = controller
    }
    
}
