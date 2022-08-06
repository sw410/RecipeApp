import UIKit
import RxCocoa
import RxSwift
import DZNEmptyDataSet
import IBAnimatable

class BaseViewController: UIViewController {
    private let haptic = UISelectionFeedbackGenerator()
    func bindViewModel() { }
    func makeUI() { }
    @objc func translation() { }
    func setupTableView() { }
    func setupCollectionView() { }
    func animateView() { }
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    var backgroundImageView = UIImageView()
    var backgroundImageEnable: Bool = true
    var enableAppLogo: Bool = false
    var enableRightMenu: Bool = false
    
    convenience init(_ backgroundEnable: Bool, enableAppLogo: Bool, enableRightMenu: Bool) {
        self.init()
        self.backgroundImageEnable = backgroundEnable
        self.enableAppLogo = enableAppLogo
        self.enableRightMenu = enableRightMenu
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.white()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func removeBack() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.backBarButtonItem = nil
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func setupAppLogo() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        let imageView = UIImageView(frame: view.frame)
        //        imageView.image = R.image.qxAppLogo()?.resize(targetSize: CGSize(width: 45, height: 45))
        //        view.addSubview(imageView)
        navigationItem.titleView = view
    }
    
    func setNavBarTransparent() {
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .clear
        self.navigationController?.navigationBar.backgroundColor = .clear
        
        //to set search controller status bar view background color in ios 13
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.titleTextAttributes = [.foregroundColor: R.color.white()!]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: R.color.white()!]
            navBarAppearance.backgroundColor = .clear
            navBarAppearance.configureWithTransparentBackground()
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
    }
    
    @objc func refresh() {
        self.headerRefreshTrigger.onNext(())
    }
    
    func setLeftBack(_ title: String = "") {
        self.navigationController?.isNavigationBarHidden = false
        //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.backButton(), style: .plain, target: self, action: #selector(self.pop))
//        let backView = LeftNavBarView.init(frame: .zero)
//        backView.title = title
//        backView.callback = { [weak self] in
//            guard let `self` = self else { return }
//            self.navigationController?.popViewController(animated: true)
//        }
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backView)
//
//        self.navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    func setLeftBackWhite() {
        self.navigationController?.isNavigationBarHidden = false
//        let backBtn = UIButton(type: .custom)
//        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        backBtn.setImage(R.image.ic_arrow_left_white()?.withRenderingMode(.alwaysOriginal), for: .normal)
//        backBtn.addTarget(self, action: #selector(self.pop), for: .touchUpInside)
//        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        let leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
//        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func setLeftBackBlack() {
        self.navigationController?.isNavigationBarHidden = false
        let backBtn = UIButton(type: .custom)
//        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        backBtn.setImage(R.image.ic_arrow_left()?.withRenderingMode(.alwaysOriginal), for: .normal)
//        backBtn.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
//        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        let leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
//        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func setLeftBackBlack2() {
        self.navigationController?.isNavigationBarHidden = false
        let backBtn = UIButton(type: .custom)
//        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        backBtn.setImage(R.image.ic_arrow_left()?.withRenderingMode(.alwaysOriginal), for: .normal)
//        backBtn.addTarget(self, action: #selector(self.pop), for: .touchUpInside)
//        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        let leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
//        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
//    func setLeftBackDismiss() {
//        self.navigationController?.isNavigationBarHidden = false
//        //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_back_white()?.resize(targetSize: DeviceType.IS_IPHONE_5 ? CGSize(width: 15, height: 20) : CGSize(width: 15, height: 20)), style: .plain, target: self, action: #selector(self.dismissView))
//        let cancelItem = UIBarButtonItem(title: L.common_cancel.rLocalized(), style: .plain, target: self, action: #selector(dismissView))
//        cancelItem.setTitleTextAttributes([.font : UIFont.fontNameAndSizeWithDevice(name: .RobotoRegular, size: DeviceType.IS_IPHONE_5 ? 12 : 14)], for: .normal)
//        cancelItem.setTitleTextAttributes([.font : UIFont.fontNameAndSizeWithDevice(name: .RobotoRegular, size: DeviceType.IS_IPHONE_5 ? 12 : 14)], for: .selected)
//        self.navigationItem.leftBarButtonItem = cancelItem
//
//        self.navigationItem.leftBarButtonItem?.tintColor = .white
//    }
//
//    func setLeftBackDismiss1() {
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_back_white()?.resize(targetSize: DeviceType.IS_IPHONE_5 ? CGSize(width: 15, height: 20) : CGSize(width: 15, height: 20)), style: .plain, target: self, action: #selector(self.dismissView))
//        self.navigationItem.leftBarButtonItem?.tintColor = .white
//    }
    
    @objc func pop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func navigateToSetting() {
//        self.navigationController?.pushViewController(SettingViewController(), animated: true)
    }
    
    deinit {
        //        self.view.endEditing(true)
        print(String(describing: type(of: self)) + "-deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension BaseViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
