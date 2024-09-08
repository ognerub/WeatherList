import Foundation

protocol WeatherServiceProtocol: AnyObject {
    func fetchWeatherFor(lat: String, lon: String, completion: @escaping (Result<WeatherEntity, Error>) -> Void)
    func fetchWeatherFor(entities: [WeatherEntity], completion: @escaping (Result<[WeatherEntity], Error>) -> Void)
}

final class WeatherService: WeatherServiceProtocol {

    private var currentTask: URLSessionTask?
    private let urlSession: URLSession
    private let builder: URLRequestBuilderProtocol

    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilderProtocol
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }

    func fetchWeatherFor(entities: [WeatherEntity], completion: @escaping (Result<[WeatherEntity], Error>) -> Void) {
        var fetchedEntities = [WeatherEntity]()
        let group = DispatchGroup()
        for entity in entities {
            group.enter()
            let lat = String(entity.lat)
            let lon = String(entity.lon)
            usleep (1000000/2)
            self.fetchWeatherFor(lat: lat, lon: lon) { result in
                switch result {
                case .success(let entity):
                    fetchedEntities.append(entity)
                case .failure(let error):
                    completion(.failure(error))
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(.success(fetchedEntities))
        }
    }

    func fetchWeatherFor(lat: String, lon: String, completion: @escaping (Result<WeatherEntity, Error>) -> Void) {
        guard let request = urlRequestUsing(lat: lat, lon: lon) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        let task = urlSession.objectTask(for: request) { (result: Result<WeatherResponse,Error>) in
            switch result {
            case .success(let result):
                let entity = WeatherEntity(
                    id: UUID(),
                    title: result.name,
                    lat: result.coord.lat,
                    lon: result.coord.lon,
                    temp: (result.main.temp - 273.15).rounded(),
                    icon: result.weather.first?.icon ?? ""
                )
                completion(.success(entity))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

private extension WeatherService {
    func urlRequestUsing(lat: String, lon: String) -> URLRequest? {
        let path: String = NetworkConstants.weatherPath
        return builder.makeWeatherHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURLString: NetworkConstants.baseUrl,
            queryItems: [
                URLQueryItem(name: "lat", value: lat),
                URLQueryItem(name: "lon", value: lon),
                URLQueryItem(name: "appid", value: NetworkConstants.apiKey)
            ]
        )
    }
}

