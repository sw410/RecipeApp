//
//  BaseNavigationController.swift
//  ReceipeApp
//
//  Created by Kok Seong Wai on 8/5/22.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializeNavBar()
        
        delegate = self
        navigationBar.isTranslucent = false
        interactivePopGestureRecognizer?.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        isNavigationBarHidden = false
    }
    
    func initializeNavBar() {
        let navBar = UINavigationBar.appearance()
        navigationItem.leftBarButtonItem?.tintColor = R.color.white()
        navigationItem.rightBarButtonItem?.tintColor = R.color.white()
        navBar.tintColor = R.color.redOrange()
        navigationBar.barTintColor = R.color.redOrange()
        navigationBar.backgroundColor = R.color.redOrange()
        navBar.shadowImage = UIImage()
        
        let navBarAttribute = [NSAttributedString.Key.font : UIFont.fontNameAndSizeWithDevice(name: .PoppinsBold, size: 16), NSAttributedString.Key.foregroundColor : R.color.black()]
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = navBarAttribute as [NSAttributedString.Key : Any]
            navBarAppearance.titleTextAttributes = navBarAttribute as [NSAttributedString.Key : Any]
            navBarAppearance.shadowImage = UIImage()
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationBar.setBackgroundImage(UIImage.imageWithColor(R.color.redOrange()!), for: UIBarMetrics.default)
        } else {
            navigationBar.setBackgroundImage(UIImage.imageWithColor(R.color.redOrange()!), for: UIBarMetrics.default)
        }
    }
}

extension BaseNavigationController: UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        if (navigationController.viewControllers.count > 1) {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        } else {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        checkTheme(navigationController: navigationController)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.viewControllers.count > 0 {
            // hide tabBar
            viewController.navigationItem.largeTitleDisplayMode = .never
            viewController.hidesBottomBarWhenPushed = true
            viewController.navigationController?.isNavigationBarHidden = false
            
            let leftBarButtonItem = UIBarButtonItem(image: R.image.ic_arrow_left_white()?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.pop))
            viewController.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.navigationController?.isNavigationBarHidden = false
        
        let leftBarButtonItem = UIBarButtonItem(image: R.image.ic_arrow_left_white()?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.pop))
        viewControllerToPresent.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    /// 返回&出栈
    @objc private func pop() {
        self.popViewController(animated: true)
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
