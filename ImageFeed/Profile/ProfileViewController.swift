import Kingfisher
import UIKit

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - Private Properties
    
    private var presenter: ProfilePresenterProtocol?
    
    // MARK: - Label
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return label
    }()
    
    lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Profile Image
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Button
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ypBlack
        presenter?.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Configure
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - SetupUI
    
    private func setupUI() {
        [profileImageView,
         logoutButton,
         nameLabel,
         loginNameLabel,
         descriptionLabel].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    // MARK: - Update Methods
    
    func updateProfileDetails(profile: Profile?) {
        guard let profile else { return }
        self.nameLabel.text = profile.name
        self.loginNameLabel.text = profile.loginName
        self.descriptionLabel.text = profile.bio
    }
    
    func updateAvatar(with url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder.jpeg"),
            options: [.processor(processor), .cacheOriginalImage]
        )
    }
    
    // MARK: - DidTapLogoutButton
    
    @objc
    private func didTapLogoutButton() {
        presenter?.didTapLogoutButton()
    }
}
