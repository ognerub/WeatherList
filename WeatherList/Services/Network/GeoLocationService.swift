import Foundation

protocol GeoLocationServiceProtocol: AnyObject {
    func fetchGeoLocationUsing(search: String, completion: @escaping (Result<GeoLocation, Error>) -> Void)
}

final class GeoLocationService: GeoLocationServiceProtocol {

    private let urlSession: URLSession
    private let builder: URLRequestBuilderProtocol
    private var currentTask: URLSessionTask?

    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilderProtocol
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }

    func fetchGeoLocationUsing(search: String, completion: @escaping (Result<GeoLocation, Error>) -> Void) {
        print("called")
        if currentTask != nil { print("canceled"); return } else {
            guard let request = urlRequestUsing(search: search) else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<GeoLocation,Error>) in
                guard let self else { return }
                self.currentTask = nil
                switch result {
                case .success(let result):
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            currentTask?.resume()
        }
    }
}

private extension GeoLocationService {
    func urlRequestUsing(search: String) -> URLRequest? {
        let path: String = "/geo/1.0/direct"
        return builder.makeWeatherHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURLString: NetworkConstants.baseUrl,
            queryItems: [
                URLQueryItem(name: "q", value: search),
                URLQueryItem(name: "limit", value: "\(1)"),
                URLQueryItem(name: "appid", value: NetworkConstants.apiKey)
            ]
        )
    }
}
