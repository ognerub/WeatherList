import Foundation

protocol GeoLocationServiceProtocol: AnyObject {
    func fetchGeoLocationUsing(search: String, completion: @escaping (Result<GeoLocation, Error>) -> Void)
}

final class GeoLocationService: GeoLocationServiceProtocol {

    private let urlSession: URLSession
    private let builder: URLRequestBuilderProtocol
    private let storage = WeatherEntitiesStore.shared
    private var currentLoad: String?

    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilderProtocol
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }

    func fetchGeoLocationUsing(search: String, completion: @escaping (Result<GeoLocation, Error>) -> Void) {
        if currentLoad != nil {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        currentLoad = search
        guard let request = urlRequestUsing(search: search) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<GeoLocation,Error>) in
            guard let self else { return }
            self.currentLoad = nil
            switch result {
            case .success(let result):
                if result.count > 0 {
                    guard let entity = result.first else {
                        completion(.failure(NetworkError.errorName))
                        return
                    }
                    if self.storage.weatherEntities.contains(where: { $0.lat.rounded() == entity.lat.rounded() && $0.lon.rounded() == entity.lon.rounded() } ) {
                        completion(.failure(NetworkError.errorDublicate))
                    } else {
                        completion(.success(result))
                    }
                } else {
                    completion(.failure(NetworkError.errorName))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

private extension GeoLocationService {
    func urlRequestUsing(search: String) -> URLRequest? {
        let path: String = NetworkConstants.geoPath
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
