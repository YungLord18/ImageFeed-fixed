import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            return keychain.string(forKey: Keys.token.rawValue)
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
