import RxRelay
import SwiftUI
import UIKit
import WebKit

final class WebLinkViewController: UIHostingController<WebLinkViewUI>, WebLinkView {
    
    var steps = PublishRelay<WebLinkViewSteps>()
    var viewModel: WebLinkViewInput!
}

struct WebLinkViewUI: View {
    
    @ObservedObject private(set) var vm: WebLinkViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if vm.model.isLoading {
                ProgressView()
                    .tint(.white)
                    .controlSize(.regular)
            }
            
            WebLinkWebView(
                isLoading: Binding(
                    get: { vm.model.isLoading },
                    set: { newValue in vm.set(isLoading: newValue) }
                ),
                error: Binding(
                    get: { vm.model.error },
                    set: { newError in vm.set(error: newError) }
                ),
                url: vm.model.homeURL,
                webLinkViewModelDelegate: vm
            )
            .modify {
                if #available(iOS 16.0, *) {
                    $0.toolbar(.hidden)
                } else {
                    $0.navigationBarHidden(true)
                }
            }
        }
        .gesture(DragGesture().onEnded { value in handleSwipeGesture(value: value) })
    }
    
    private func handleSwipeGesture(value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
        let verticalAmount = value.translation.height
        
        if abs(horizontalAmount) > abs(verticalAmount) {
            if horizontalAmount > 50 {
                vm.navigateBack()
            } else if horizontalAmount < -50 {
                vm.navigateForward()
            }
        }
    }
}

protocol WebLinkWebViewCoordinatorDelegate: AnyObject {
    
    func goForward()
    func goBack()
}

private struct WebLinkWebView: UIViewRepresentable {
    
    @Binding var isLoading: Bool
    @Binding var error: Error?
    let url: URL
    let webLinkViewModelDelegate: WebLinkViewModelDelegate
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WebViewConfigurator.make()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, webLinkViewModelDelegate: webLinkViewModelDelegate)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
        
        var parent: WebLinkWebView
        var webLinkViewModelDelegate: WebLinkViewModelDelegate
        private var visitedUrls = Set<String>()
        private var redirectCount = 0
        private let maxRedirects = 10
        private var observer: NSObjectProtocol?
        
        init(parent: WebLinkWebView,
             webLinkViewModelDelegate: WebLinkViewModelDelegate) {
            self.parent = parent
            self.webLinkViewModelDelegate = webLinkViewModelDelegate
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webLinkViewModelDelegate.accept(canGoBack: webView.canGoBack)
            webLinkViewModelDelegate.accept(canGoForward: webView.canGoForward)
            webLinkViewModelDelegate.accept(currentURL: webView.url)
            
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            
            print("ℹ️ navigationAction URL: \(url.absoluteString)")
            
            if shouldOpenInExternalApp(url: url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    NSLog("ℹ️ navigationAction URL opened in external app: \(success)")
                }
                decisionHandler(.cancel)
                return
            } else {
                let urlString = url.absoluteString
                
                // Check for redirect loops
                if visitedUrls.contains(urlString) || redirectCount > maxRedirects {
                    decisionHandler(.cancel)
                    handleRedirectLoop(in: webView, url: url)
                    return
                }
                
                if urlString != "about:blank" {
                    visitedUrls.insert(urlString)
                    redirectCount += 1
                }
                decisionHandler(.allow)
            }
        }
        
//        func webView(_ webView: WKWebView,
//                     createWebViewWith configuration: WKWebViewConfiguration,
//                     for navigationAction: WKNavigationAction,
//                     windowFeatures: WKWindowFeatures) -> WKWebView? {
//            let newConfiguration =  WKWebViewConfiguration()
//            newConfiguration.websiteDataStore = configuration.websiteDataStore
//            newConfiguration.processPool = configuration.processPool
//            newConfiguration.allowsInlineMediaPlayback = true
//            newConfiguration.mediaTypesRequiringUserActionForPlayback = []
//            
//            // Disable content scaling on rotation
//            let source: String = """
//                        var meta = document.createElement('meta');
//                        meta.name = 'viewport';
//                        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
//                        document.getElementsByTagName('head')[0].appendChild(meta);
//                    """
//            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//            newConfiguration.userContentController.addUserScript(script)
//            
//            let preferences = WKWebpagePreferences()
//            preferences.allowsContentJavaScript = true
//            newConfiguration.defaultWebpagePreferences = preferences
//            
//            let newWebView = WKWebView(frame: .zero, configuration: configuration)
//            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            webView.isOpaque = false
//            webView.backgroundColor = .clear
//            webView.scrollView.backgroundColor = .clear
//            webView.scrollView.contentInsetAdjustmentBehavior = .never
//            webView.allowsBackForwardNavigationGestures = true
//            webView.translatesAutoresizingMaskIntoConstraints = false
//            webView.scrollView.minimumZoomScale = 1.0
//            webView.scrollView.maximumZoomScale = 1.0
//            webView.scrollView.bouncesZoom = false
//            
//            webView.navigationDelegate = self
//            webView.uiDelegate = self
//            webView.scrollView.delegate = self
//            
//            if #available(iOS 16.4, *) {
//                webView.isInspectable = true
//            }
//            
//            let newWebViewController = UIViewController()
//            newWebViewController.view = newWebView
//            
//            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
//                rootVC.present(newWebViewController, animated: true, completion: nil)
//            }
//            
//            return newWebView
//        }
        
        func webViewDidClose(_ webView: WKWebView) {
            if let presentingVC = webView.window?.rootViewController?.presentedViewController {
                presentingVC.dismiss(animated: true, completion: nil)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleNavigationError(error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleNavigationError(error)
        }
        
        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            scrollView.pinchGestureRecognizer?.isEnabled = false
        }
        
        private func shouldOpenInExternalApp(url: URL) -> Bool {
            let deepLinkSchemes = ["paytmmp", "phonepe", "bankid"]
            return deepLinkSchemes.contains(url.scheme?.lowercased() ?? "")
        }
        
        private func handleRedirectLoop(in webView: WKWebView, url: URL) {
            parent.error = NSError(
                domain: "WebViewError",
                code: -100,
                userInfo: [NSLocalizedDescriptionKey: "Redirect loop detected"]
            )
            
            // Break the cycle by loading without cookies
            var request = URLRequest(url: url)
            request.httpShouldHandleCookies = true
            webView.load(request)
            
            // Reset state
            visitedUrls.removeAll()
            redirectCount = 0
        }
        
        private func handleNavigationError(_ error: Error) {
            parent.isLoading = false
            parent.error = error
        }
    }
}

enum WebViewConfigurator {
    
    private static let sharedProcessPool = WKProcessPool()
    
    static func make() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.processPool = Self.sharedProcessPool
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Disable content scaling on rotation
        let source: String = """
                    var meta = document.createElement('meta');
                    meta.name = 'viewport';
                    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                    document.getElementsByTagName('head')[0].appendChild(meta);
                """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bouncesZoom = false
        
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        return webView
    }
}
