import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    
//MARK: - Static Properties
    
    static let shared = OAuth2TokenStorage()
    
//MARK: - Public Properties
    
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
    
//MARK: - Private Initializers
    
    private init() {}
    
//MARK: - Private Properties
    
    private let keychain = KeychainWrapper.standard
    
//MARK: - Public Methods
    
    func logout() {
        keychain.removeObject(forKey: Keys.token.rawValue)
    }
    
//MARK: - Private Enum
    
    private enum Keys: String {
        case token
    }
}
