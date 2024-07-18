import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
    func fetchProfile(_ token: String)
}

final class AuthViewController: UIViewController {
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared

    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButtonAppearance()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == ShowWebViewSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard
            let webViewViewController = segue.destination as? WebViewViewController
        else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
        webViewViewController.delegate = self
    }
    
    private func setupBackButtonAppearance() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    private func showAlertError() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Ок",
            style: .default))
        self.present(alert, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        UIBlockingProgressHUD.show()
        delegate?.didAuthenticate(self)
        oauth2Service.fetchOAuthToken(withCode: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                print("Авторизационный токен получен: \(token)")
                delegate?.fetchProfile(token)
            case .failure(let error):
                print("Ошибка получения токена: \(error.localizedDescription)")
                self.showAlertError()
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
