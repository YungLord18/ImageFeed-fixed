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
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(ShowWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
