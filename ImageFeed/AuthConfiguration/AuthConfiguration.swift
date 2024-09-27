import Foundation

// MARK: - Struct

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    let urlComponentsURLString: String
    let urlComponentsPath: String
    let baseURL: String
    let urlProfilePath: String
    let urlUsersPath: String
    let photosLike: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL!,
            authURLString: WebViewConstants.unsplashAuthorizeURLString,
            urlComponentsURLString: Constants.urlComponentsURLString,
            urlComponentsPath: WebViewConstants.urlComponentsPath,
            baseURL: OAuthConstants.baseURL,
            urlProfilePath: ProfileConstants.urlProfilePath,
            urlUsersPath: ProfileConstants.urlUsersPath,
            photosLike: PhotosLikeConstants.photosLike
        )
    }
    
    // MARK: - Initializers
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseURL: URL,
        authURLString: String,
        urlComponentsURLString: String,
        urlComponentsPath: String,
        baseURL: String,
        urlProfilePath: String,
        urlUsersPath: String,
        photosLike: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
        self.urlComponentsURLString = urlComponentsURLString
        self.urlComponentsPath = urlComponentsPath
        self.baseURL = baseURL
        self.urlProfilePath = urlProfilePath
        self.urlUsersPath = urlUsersPath
        self.photosLike = photosLike
    }
}
