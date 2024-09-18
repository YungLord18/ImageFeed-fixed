@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    var presenterSpy: ProfilePresenterSpy!
    var viewController: ProfileViewController!
    
    override func setUp() {
        super.setUp()
        presenterSpy = ProfilePresenterSpy()
        viewController = ProfileViewController()
        viewController.configure(presenterSpy)
        _ = viewController.view
    }
    
    override func tearDown() {
        viewController = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func testViewDidLoadPresenterCalled() {
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testUpdateAvatarInvalidURL() {
        let invalidURL = URL(string: "invalid-url")!
        viewController.updateAvatar(with: invalidURL)
        XCTAssertNil(viewController.profileImageView.image)
    }
    
    func testLogoutButtonCallsPresenter() {
        let logoutButton = viewController.logoutButton
        logoutButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(presenterSpy.didTapLogoutButtonCalled)
    }
    
    func testPresenterUpdatesProfileDetails() {
        let profileResult = ProfileResult(
            username: "testuser",
            firstName: "Test",
            lastName: "User",
            bio: "This is a test bio")
        let profile = Profile(result: profileResult)
        viewController.updateProfileDetails(profile: profile)
        XCTAssertEqual(viewController.nameLabel.text, profile.name)
        XCTAssertEqual(viewController.loginNameLabel.text, profile.loginName)
        XCTAssertEqual(viewController.descriptionLabel.text, profile.bio)
    }
    
    func testUpdateAvatarSetsImageView() {
        let mockImage = UIImage(systemName: "person.circle")!
        let imageView = viewController.profileImageView
        imageView.image = mockImage
        XCTAssertNotNil(imageView.image)
    }
    
    func testSetupUI() {
        XCTAssertTrue(viewController.view.subviews.contains(viewController.profileImageView))
        XCTAssertTrue(viewController.view.subviews.contains(viewController.logoutButton))
        XCTAssertTrue(viewController.view.subviews.contains(viewController.nameLabel))
        XCTAssertTrue(viewController.view.subviews.contains(viewController.loginNameLabel))
        XCTAssertTrue(viewController.view.subviews.contains(viewController.descriptionLabel))
        XCTAssertNotNil(viewController.profileImageView.constraints)
        XCTAssertNotNil(viewController.logoutButton.constraints)
        XCTAssertNotNil(viewController.nameLabel.constraints)
        XCTAssertNotNil(viewController.loginNameLabel.constraints)
        XCTAssertNotNil(viewController.descriptionLabel.constraints)
    }
}
