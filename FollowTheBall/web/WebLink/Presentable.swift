import RxSwift
import UIKit

protocol Presentable: AnyObject {
    
    var root: UIViewController { get }
    
    var stepsBag: DisposeBag { get }
}

private var stepsBagAssociation = UInt8()

extension UIViewController: Presentable {
    
    var root: UIViewController {
        self
    }
    
    var stepsBag: DisposeBag {
        if let stepsBag = objc_getAssociatedObject(self, &stepsBagAssociation) as? DisposeBag {
            return stepsBag
        } else {
            let stepsBag = DisposeBag()
            objc_setAssociatedObject(self, &stepsBagAssociation, stepsBag, .OBJC_ASSOCIATION_RETAIN)
            return stepsBag
        }
    }
}
