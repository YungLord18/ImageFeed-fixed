import UIKit
import Kingfisher

final class ImageListService {
    
    // MARK: - Static Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImageListService()
    
    // MARK: - Private Properties
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading: Bool = false
    private var storage = OAuth2TokenStorage.shared
    private let dateFormatter = ISO8601DateFormatter()
    
    // MARK: - Private Init
    
    private init() {}
    
    // MARK: - Methodc
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            if indexPath.row + 1 == photos.count {
                fetchPhotosNextPage()
            }
        }
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let token = storage.token, let request = createPhotoRequest(page: nextPage, token: token) else {
            isLoading = false
            return
        }
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if error != nil {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            do {
                let photoResult = try JSONDecoder().decode([PhotoResult].self, from: data)
                DispatchQueue.main.async {
                    self.lastLoadedPage = nextPage
                    self.preparePhoto(photoResult: photoResult)
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos])
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        task.resume()
    }
    
    private func preparePhoto(photoResult: [PhotoResult]) {
        let newPhotos = photoResult.compactMap { item -> Photo? in
            guard let createdAtString = item.createdAt,
                  let createdAtDate = dateFormatter.date(from: createdAtString) else {
                print("Дата создания для фотографии с ID \(item.id) отсутствует или имеет неверный формат.")
                return nil
            }
            return Photo(
                id: item.id,
                size: CGSize(width: item.width, height: item.height),
                createdAt: createdAtDate,
                welcomeDescription: item.description,
                thumbImageURL: item.urls.regular,
                fullImageUrl: item.urls.full,
                isLiked: item.isLiked)
        }
        photos.append(contentsOf: newPhotos)
    }
    
    private func createPhotoRequest(
        page: Int,
        token: String) -> URLRequest? {
            guard let url = URL(string: "\(String(describing: Constants.defaultBaseURL))/photos?page=\(page)&per_page=10") else
            { return nil }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let token = storage.token else {
            completion(.failure(NetworkError.authorizationError))
            return
        }
        let urlString = "\(likePhoto.likePhoto)/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.unknownError))
                }
                return
            }
            switch httpResponse.statusCode {
            case 200...299:
                self.updatePhotoLikeStatus(photoId: photoId, isLiked: isLike)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            default:
                let error = NetworkErrorHandler.handleErrorResponse(statusCode: httpResponse.statusCode)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    private func updatePhotoLikeStatus(
        photoId: String,
        isLiked: Bool
    ) {
        DispatchQueue.main.async {
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                let newPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    fullImageUrl: photo.fullImageUrl,
                    isLiked: isLiked
                )
                self.photos[index] = newPhoto
            } else {
                print("Фотография с ID \(photoId) не найдена.")
            }
        }
    }
}

extension ImageListService {
    func clearImageList() {
        photos.removeAll()
        lastLoadedPage = nil
    }
}

// MARK: - Struct

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let fullImageUrl: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResult
    let isLiked: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case urls
        case isLiked = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let regular: String
    let full: String
}
