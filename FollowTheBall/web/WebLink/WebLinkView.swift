import RxRelay

enum WebLinkViewSteps {
    
}

protocol WebLinkViewOutput: AnyObject {
    
    var steps: PublishRelay<WebLinkViewSteps> { get }
}

protocol WebLinkViewInput {
    
    func bind(output: WebLinkViewOutput)
}

protocol WebLinkView: Presentable, WebLinkViewOutput {
    
    var viewModel: WebLinkViewInput! { get set }
}
