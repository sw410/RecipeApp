import Foundation
import RxSwift
import RxCocoa
import TLPhotoPicker

class BaseViewModel: NSObject {
//    let loading = ActivityIndicator()
//    let headerLoading = ActivityIndicator()
//    let footerLoading = ActivityIndicator()
    let showLoading : BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    let showHeaderLoading : BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    let errorTracker = ErrorTracker()
    var page = BehaviorRelay<Int>.init(value: 0)
    let itemCount = BehaviorRelay<Int>.init(value: 0)
    
    func count(from: Int, to: Int, quickStart: Bool) -> Observable<Int> {
        return Observable<Int>
            .timer(quickStart ? 0 : 1, period: 1, scheduler: MainScheduler.instance)
            .take(from - to + 1)
            .map { from - $0 }
    }
    
    func getImageURL(assets: TLPHAsset, _ completionHandler: @escaping (URL) -> ()) {
        assets.tempCopyMediaFile { (url, string) in
            completionHandler(url)
        }
    }
    
    deinit {
        print(String(describing: type(of: self)) + "-deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
