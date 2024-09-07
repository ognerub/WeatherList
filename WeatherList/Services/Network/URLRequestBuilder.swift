import Foundation

protocol URLRequestBuilderProtocol {
    func makeWeatherHTTPRequest(
        path: String,
        httpMethod: String,
        baseURLString: String,
        queryItems: [URLQueryItem]
    ) -> URLRequest?
}

final class URLRequestBuilder: URLRequestBuilderProtocol {
    func makeWeatherHTTPRequest(
        path: String,
        httpMethod: String,
        baseURLString: String,
        queryItems: [URLQueryItem]
    ) -> URLRequest?  {
        let turple = makeBaseRequestAndURL(
            path: path,
            httpMethod: httpMethod,
            baseURLString: baseURLString)
        var request: URLRequest = turple.0
        let baseURL: URL = turple.1
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems
        guard let comurl = components?.url else { return nil }
        request.url = comurl
        return request
    }

    private func makeBaseRequestAndURL(
        path: String,
        httpMethod: String,
        baseURLString: String
    ) -> (URLRequest, URL) {
        let emptyURL = URL(fileURLWithPath: "")
        guard
            baseURLString.isValidURL,
            let url = URL(string: baseURLString),
            let baseURL = URL(string: path, relativeTo: url)
        else {
            assertionFailure("Impossible to create URLRequest from URL")
            return (URLRequest(url: emptyURL), emptyURL)
        }

        var request = URLRequest(url: baseURL)
        request.httpMethod = httpMethod
        request.timeoutInterval = 10
        return (request, baseURL)
    }
}
