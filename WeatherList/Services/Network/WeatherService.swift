import Foundation

protocol WeatherServiceProtocol: AnyObject {
    func fetchWeatherFor(lat: String, lon: String, completion: @escaping (Result<WeatherEntity, Error>) -> Void)
    func fetchWeatherFor(entities: [WeatherEntity], completion: @escaping (Result<[WeatherEntity], Error>) -> Void)
}

final class WeatherService: WeatherServiceProtocol {

    private let urlSession: URLSession
    private let builder: URLRequestBuilderProtocol
    private var currentTasks = [String]()

    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilderProtocol
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }

    func fetchWeatherFor(entities: [WeatherEntity], completion: @escaping (Result<[WeatherEntity], Error>) -> Void) {
        currentTasks = []
        var fetchedEntities = [WeatherEntity]()
        let group = DispatchGroup()
        for entity in entities {
            group.enter()
            let lat = String(entity.lat)
            let lon = String(entity.lon)
            fetchWeatherFor(lat: lat, lon: lon, completion: { result in
                switch result {
                case .success(let entity):
                    fetchedEntities.append(entity)
                case .failure(let error):
                    completion(.failure(error))
                }
                group.leave()
            })
        }
        group.notify(queue: .main) {
            let sortedEntities = fetchedEntities.sorted { $0.title < $1.title }
            completion(.success(sortedEntities))
        }
    }

    func fetchWeatherFor(lat: String, lon: String, completion: @escaping (Result<WeatherEntity, Error>) -> Void) {
        let taskString = "\(lat) \(lon)"
        if currentTasks.contains(taskString) {
            return
        }
        guard let request = urlRequestUsing(lat: lat, lon: lon) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<WeatherResponse,Error>) in
            guard let self else { return }
            switch result {
            case .success(let result):
                let entity = WeatherEntity(
                    id: UUID(),
                    title: result.name,
                    lat: result.coord.lat,
                    lon: result.coord.lon,
                    temp: result.main.temp,
                    icon: result.weather.first?.icon ?? ""
                )
                completion(.success(entity))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        currentTasks.append(taskString)
        task.resume()
    }
}

private extension WeatherService {
    func urlRequestUsing(lat: String, lon: String) -> URLRequest? {
        let path: String = "/data/2.5/weather?"
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

