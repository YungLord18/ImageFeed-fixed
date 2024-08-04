import Foundation
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        let alert = UIAlertController(
            title: "Выход из аккаунта",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Подтвердить",
            style: .destructive,
            handler: { _ in
                self.cleanCookies()
                self.clearLocalData()
                self.switchToSplashViewController()
            }))
        alert.addAction(UIAlertAction(
            title: "Отмена",
            style: .cancel,
            handler: nil))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
        { records in records.forEach
            { record in WKWebsiteDataStore.default().removeData(
                ofTypes: record.dataTypes,
                for: [record],
                completionHandler: {})
            }
        }
    }
    
    private func clearLocalData() {
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearProfileImage()
        ImageListService.shared.clearImageList()
        OAuth2TokenStorage.shared.logout()
    }
    
    private func switchToSplashViewController() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                assertionFailure("Не удалось получить windowScene или window")
                return
            }
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
            window.makeKeyAndVisible()
        }
    }
}
