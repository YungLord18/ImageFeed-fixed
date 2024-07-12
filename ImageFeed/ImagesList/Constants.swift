import Foundation

enum Constants {
    static let accessKey = "Mg0HD6jMC4P_I0FZTVWC68P7VP5XOhQfP_OvlzjrJsk"
    static let secretKey = "UI6IrAmgZh7idh7fsGJN2ObuVZxo1CCVG-0GNZrYHfU"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let urlComponentsURLString = "https://unsplash.com/oauth/token"
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let urlComponentsPath = "/oauth/authorize/native"
}

enum OAuthConstants {
    static let baseURL = "https://unsplash.com"
}

enum ProfileConstants {
    static let urlProfilePath = "https://api.unsplash.com/me"
    static let urlUsersPath = "https://api.unsplash.com/users/"
}
