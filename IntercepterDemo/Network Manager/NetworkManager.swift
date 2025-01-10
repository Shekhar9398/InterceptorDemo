import Foundation
import SwiftUI

// MARK: - RequestInterceptor Protocol
protocol RequestInterceptor {
    func intercept(request: URLRequest) -> URLRequest
    func shouldRetry(response: URLResponse?, error: Error?) -> Bool
}

// MARK: - AuthInterceptor
class AuthInterceptor: RequestInterceptor {
    
    private var accessToken = "Bearer abc123xyz-token"
    private var refreshToken = "xyz-refresh-token"
    
    // MARK: - Intercept Request
    func intercept(request: URLRequest) -> URLRequest {
        var interceptedRequest = request
        interceptedRequest.addValue(accessToken, forHTTPHeaderField: "Authorization")
        return interceptedRequest
    }
    
    // MARK: - Should Retry
    func shouldRetry(response: URLResponse?, error: Error?) -> Bool {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                refreshTokenIfNeeded { success in
                    if success {
                        print("Token refreshed, retrying the request...")
                    } else {
                        print("Token refresh failed, cannot retry.")
                    }
                }
                return false
            }
            if (500...599).contains(httpResponse.statusCode) {
                return true
            }
        }
        return error != nil
    }
    
    // MARK: - Refresh Token
    private func refreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let newAccessToken = "Bearer new-access-token"
            self.accessToken = newAccessToken
            completion(true)
        }
    }
}

// MARK: - NetworkManager
class NetworkManager {
    static let shared = NetworkManager()
    
    private let interceptor: RequestInterceptor
    private let maxRetryCount = 3
    
    private init(interceptor: RequestInterceptor = AuthInterceptor()) {
        self.interceptor = interceptor
    }
    
    // MARK: - Fetch Data
    func fetchData<T: Decodable>(urlString: String, model: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        let interceptedRequest = interceptor.intercept(request: request)
        performRequest(request: interceptedRequest, retryCount: 0, model: model, completion: completion)
    }
    
    // MARK: - Perform Request
    private func performRequest<T: Decodable>(request: URLRequest, retryCount: Int, model: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if self.interceptor.shouldRetry(response: response, error: error), retryCount < self.maxRetryCount {
                print("Retrying request... (\(retryCount + 1)/\(self.maxRetryCount))")
                self.performRequest(request: request, retryCount: retryCount + 1, model: model, completion: completion)
                return
            }
            
            if let error = error {
                completion(.failure(.decodingError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch let decodingError {
                completion(.failure(.decodingError(decodingError)))
            }
        }
        task.resume()
    }
    
    // MARK: - Network Error Enum
    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError(Error)
        case unauthorized
        case serverError
    }
}
