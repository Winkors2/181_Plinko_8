import Foundation

struct WebLinkModel {
    
    let homeURL: URL
    private(set) var isLoading: Bool
    private(set) var error: Error?
    private(set) var canGoBack: Bool
    private(set) var canGoForward: Bool
    private(set) var currentURL: URL?
    
    init(homeURL: URL,
         isLoading: Bool = true,
         error: Error? = nil,
         canGoBack: Bool = false,
         canGoForward: Bool = false,
         currentURL: URL? = nil) {
        self.homeURL = homeURL
        self.isLoading = isLoading
        self.error = error
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.currentURL = currentURL
    }
}

// MARK: Extensions

extension WebLinkModel {
    
    mutating func accept(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    mutating func accept(error: Error?) {
        self.error = error
    }
    
    mutating func accept(canGoBack: Bool) {
        self.canGoBack = canGoBack
    }
    
    mutating func accept(canGoForward: Bool) {
        self.canGoForward = canGoForward
    }
    
    mutating func accept(currentURL: URL?) {
        self.currentURL = currentURL
    }
}
