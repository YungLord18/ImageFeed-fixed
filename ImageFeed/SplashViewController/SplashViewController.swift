import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage.shared
    
    // MARK: - ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchProfileIfNeeded()
        
        view.backgroundColor = .ypBlack
        
        let vectorImageView = UIImageView(image: UIImage(named: "vector_logo"))
        vectorImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vectorImageView)
        
        NSLayoutConstraint.activate([
            vectorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vectorImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Status BarStyle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    
    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                print(NetworkError.windowSceneError)
                return
            }
            guard let window = windowScene.windows.first else {
                print(NetworkError.windowError)
                return
            }
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default))
        self.present(alert, animated: true)
    }
    
    private func fetchProfileIfNeeded() {
        if let token = storage.token {
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

// MARK: - AuthViewControllerDelegate

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
}
