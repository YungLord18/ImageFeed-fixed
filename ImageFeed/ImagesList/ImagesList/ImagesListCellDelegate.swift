import Foundation


protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func didSelectRowAt(indexPath: IndexPath)
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLikeButton(at indexPath: IndexPath)
}

public protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableView(with indexPaths: [IndexPath], animated: Bool)
    func navigateToImageController(with url: String)
    func updateLikeButton(at indexPath: IndexPath, isLiked: Bool)
}
