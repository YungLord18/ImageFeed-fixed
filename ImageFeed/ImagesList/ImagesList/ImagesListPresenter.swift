import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {

    weak var view: ImagesListViewControllerProtocol?
    
    private let imageListService: ImageListService
    
    init(imageListService: ImageListService = .shared) {
        self.imageListService = imageListService
    }
    
    func viewDidLoad() {
        imageListService.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self, let newPhotos = notification.userInfo?["photos"] as? [Photo] else {
                return
            }
            self.handleNewPhotos(newPhotos)
        }
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        let photo = imageListService.photos[indexPath.row]
        view?.navigateToImageController(with: photo.fullImageUrl)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLikeButton(at indexPath: IndexPath) {
        let photo = imageListService.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.view?.updateLikeButton(at: indexPath, isLiked: !photo.isLiked)
            case .failure(let error):
                print("Не удалось поставить лайк: \(error)")
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func handleNewPhotos(_ newPhotos: [Photo]) {
        let oldCount = imageListService.photos.count - newPhotos.count
        let newCount = imageListService.photos.count
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        if let viewController = view as? ImagesListViewController {
            viewController.photos.append(contentsOf: newPhotos)
            viewController.updateTableView(with: indexPaths, animated: true)
        }
    }
}
