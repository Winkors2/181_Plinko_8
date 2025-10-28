import Foundation
import FirebaseCore
import FirebaseFirestore
import UIKit


struct UserResponse: Decodable {
    let status: Bool
    let privacyPolicy: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case privacyPolicy = "privacy_policy"
    }
}

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    
    func registerUser(completion: @escaping (Result<UserResponse, Error>) -> Void) {
        let functionUrl = "https://europe-west1-apps-a354b.cloudfunctions.net/registerUser"
        
        guard let url = URL(string: functionUrl) else {
            print("Url is not available")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bundleID = Bundle.main.bundleIdentifier ?? "com.example1.Shield"
        let vendorID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        let bodyData: [String: Any] = [
            "bundleID": bundleID,
            "identifierForVendor": vendorID,
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: bodyData)
            request.httpBody = jsonData
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                
                completion(.failure(error))
                return
            }
                
                guard let data = data else {
                    let error = NSError(domain: "FirebaseManager", code: 1002, userInfo: [NSLocalizedDescriptionKey: "No data"])
                    completion(.failure(error))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let userResponse = try decoder.decode(UserResponse.self, from: data)
                    
                    
                    // Добавляем задержку в 3 секунды перед возвратом ответа
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        
                        completion(.success(userResponse))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            print(error.localizedDescription)
            completion(.failure(error))
        }
    }
}

