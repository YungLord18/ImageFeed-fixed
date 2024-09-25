@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    var viewController: ImagesListViewController!
    var presenterSpy: ImagesListPresenterSpy!
    var viewControllerSpy: ImagesListViewControllerSpy!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as? ImagesListViewController
        presenterSpy = ImagesListPresenterSpy()
        viewControllerSpy = ImagesListViewControllerSpy()
        viewController.configure(presenterSpy)
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        presenterSpy = nil
        viewControllerSpy = nil
        super.tearDown()
    }
    
    func testViewControllerCallsViewDidLoad() {
        _ = viewController.view
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testConfigureWithPresenter() {
        viewController.configure(presenterSpy)
        XCTAssertNotNil(presenterSpy.view)
        XCTAssertTrue(presenterSpy.view === viewController)
    }

    func testUpdateTableViewWithNewPhotos() {
        let newPhotos = [Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(), welcomeDescription: "Description",
            thumbImageURL: "thumbURL",
            fullImageUrl: "fullURL",
            isLiked: false)]
        viewController.photos.append(contentsOf: newPhotos)
        viewController.updateTableView(with: [IndexPath(row: 0, section: 0)], animated: false)
        XCTAssertEqual(viewController.photos.count, 1)
        XCTAssertEqual(viewController.photos.first?.id, "1")
    }
    
    func testNavigateToImageController() {
        viewControllerSpy.navigateToImageController(
            with: "https://api.unsplash.com/photos?page=/page&per_page=10")
        presenterSpy.didSelectRowAt(indexPath: IndexPath(row: 0, section: 0))
        XCTAssertTrue(viewControllerSpy.navigateToImageControllerCalled)
    }
    
    func testDidSelectRowAt() {
        let indexPath = IndexPath(row: 0, section: 0)
        viewController.tableView(viewController.tableView, didSelectRowAt: indexPath)
        XCTAssertTrue(presenterSpy.didSelectRowAtCalled)
    }
    
    func testWillDisplayCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = UITableViewCell()
        viewController.tableView(viewController.tableView, willDisplay: cell, forRowAt: indexPath)
        XCTAssertTrue(presenterSpy.willDisplayCellCalled)
    }
}
