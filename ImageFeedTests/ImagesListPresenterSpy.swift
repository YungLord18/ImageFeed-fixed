import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false
    var didSelectRowAtCalled = false
    var willDisplayCellCalled = false
    var didTapLikeButtonCalled = false
    
    func viewDidLoad() { viewDidLoadCalled = true }
    func didSelectRowAt(indexPath: IndexPath) { didSelectRowAtCalled = true }
    func willDisplayCell(at indexPath: IndexPath) { willDisplayCellCalled = true }
    func didTapLikeButton(at indexPath: IndexPath) { didTapLikeButtonCalled = true }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewCalled = false
    var navigateToImageControllerCalled = false
    var updateLikeButtonCalled = false
    
    func updateTableView(with indexPaths: [IndexPath], animated: Bool) { updateTableViewCalled = true }
    func navigateToImageController(with url: String) { navigateToImageControllerCalled = true }
    func updateLikeButton(at indexPath: IndexPath, isLiked: Bool) { updateLikeButtonCalled = true }
}
