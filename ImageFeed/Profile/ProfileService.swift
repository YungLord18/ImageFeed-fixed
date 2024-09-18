import UIKit

final class ProfileService {
    
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private init() {}
    
    private func createProfileURLRequest(token: String) -> URLRequest? {
        guard let profileURL = URL(string: ProfileConstants.urlProfilePath) else {
            print(NetworkError.invalidURL)
            return nil
        }
        var request = URLRequest(url: profileURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<(Profile, String), Error>) -> Void
    ) {
        task?.cancel()
        guard let request = createProfileURLRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                }
            }
            guard let self = self else { return }
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
            case 200:
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.emptyData))
                    }
                    return
                }
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = Profile(result: profileResult)
                    self.profile = profile
                    DispatchQueue.main.async {
                        completion(.success((profile, profileResult.username)))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            default:
                let error = NetworkErrorHandler.handleErrorResponse(statusCode: httpResponse.statusCode)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task?.resume()
    }
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case bio
    }
}

public struct Profile: Decodable {
    let username: String
    let name: String?
    let loginName: String
    let bio: String?
    
    init(result: ProfileResult) {
        self.username = result.username
        self.name = "\(result.firstName ?? "") \(result.lastName ?? "")"
        self.loginName = "@\(result.username)"
        self.bio = result.bio
    }
}

extension ProfileService {
    func clearProfile() {
        profile = nil
    }
}
