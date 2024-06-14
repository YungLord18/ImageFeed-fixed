import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    init() {}
    
    let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
