import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                keychain.set(token, forKey: Keys.token.rawValue)
            } else {
                keychain.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
    
    private init() {}
    
    private let keychain = KeychainWrapper.standard
    
    func logout() {
        keychain.removeObject(forKey: Keys.token.rawValue)
    }
    
    private enum Keys: String {
        case token
    }
}
