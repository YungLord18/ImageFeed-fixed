import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchProfileIfNeeded()
        
        view.backgroundColor = .black
        
        let vectorImageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        vectorImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vectorImageView)
        
        NSLayoutConstraint.activate([
            vectorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vectorImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
        } else {
            showAuthenticationScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { fatalError("Could not find window scene") }
        guard let window = windowScene.windows.first else {
            fatalError("Could not find a window") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default))
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true)
        }
    }
    
    private func fetchProfileIfNeeded() {
        if let token = oauth2TokenStorage.token {
            UIBlockingProgressHUD.show()
            fetchProfile(token)
        } else {
            showAuthenticationScreen()
        }
    }
    
    private func showAuthenticationScreen() {
        guard let authViewController = UIStoryboard(
            name: "Main",
            bundle: .main).instantiateViewController(
                withIdentifier: "AuthViewController") as? AuthViewController else {
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func fetchProfile(_ token: String) {
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let (_, username)):
                    ProfileImageService.shared.fetchProfileImageURL(
                        username: username,
                        token: token) { _ in }
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    self.showErrorMessage("Не удалось получить профиль: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchProfileIfNeeded()
        }
    }
    
    
    private func fetchOAuthToken(_ token: String) {
        oauth2Service.fetchOAuthToken(withCode: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let code):
                self.fetchProfile(code)
            case .failure:
                self.showErrorMessage("Что-то пошло не так")
            }
        }
    }
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
}
