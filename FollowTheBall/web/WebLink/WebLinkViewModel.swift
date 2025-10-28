import UIKit
import Combine
protocol WebLinkViewModelDelegate: AnyObject {
    
    func bind(webLinkWebViewCoordinatorDelegate: WebLinkWebViewCoordinatorDelegate)
    
    func accept(canGoBack: Bool)
    func accept(canGoForward: Bool)
    func accept(currentURL: URL?)
}

final class WebLinkViewModel: ObservableObject {
    
    @Published var model: WebLinkModel
    
    private weak var output: WebLinkViewOutput?
    private weak var webLinkWebViewCoordinatorDelegate: WebLinkWebViewCoordinatorDelegate?
    
    init(model: WebLinkModel) {
        self.model = model
    }
    
    func set(isLoading: Bool) { model.accept(isLoading: isLoading) }
    
    func set(error: Error?) { model.accept(error: error) }
    
    func navigateForward() { handleNavigateForward() }
    
    func navigateBack() { handleNavigateBack() }
}

private extension WebLinkViewModel {
    
    private func handleNavigateForward() {
        if model.canGoForward {
            webLinkWebViewCoordinatorDelegate?.goForward()
        }
    }
    
    private func handleNavigateBack() {
        if model.canGoBack {
            webLinkWebViewCoordinatorDelegate?.goBack()
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}

extension WebLinkViewModel: WebLinkViewInput {
    
    func bind(output: WebLinkViewOutput) {
        self.output = output
    }
}

extension WebLinkViewModel: WebLinkViewModelDelegate {
    
    func bind(webLinkWebViewCoordinatorDelegate: WebLinkWebViewCoordinatorDelegate) {
        self.webLinkWebViewCoordinatorDelegate = webLinkWebViewCoordinatorDelegate
    }
    
    func accept(canGoBack: Bool) {
        model.accept(canGoBack: canGoBack)
    }
    
    func accept(canGoForward: Bool) {
        model.accept(canGoForward: canGoForward)
    }
    
    func accept(currentURL: URL?) {
        model.accept(currentURL: currentURL)
    }
}
