import SwiftUI
import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var status: Bool?
    @Published var privacyPolicy: String?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func registerUser() {
        isLoading = true
        FirebaseManager.shared.registerUser { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.status = response.status
                    self?.privacyPolicy = response.privacyPolicy
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

