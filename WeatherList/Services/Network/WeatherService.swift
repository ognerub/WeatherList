import Foundation

protocol WeatherServiceProtocol: AnyObject {
    func fetchWeatherFor(entity: WeatherEntity?, element: GeoLocationResponse?, completion: @escaping (Result<WeatherEntity, Error>) -> Void)
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
            usleep (1000000/2)
            self.fetchWeatherFor(entity: entity) { result in
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

    func fetchWeatherFor(entity: WeatherEntity? = nil, element: GeoLocationResponse? = nil, completion: @escaping (Result<WeatherEntity, Error>) -> Void) {
        var latitude = String()
        var longitude = String()
        if let element = element {
            latitude = String(element.lat)
            longitude = String(element.lon)
        } else if let entity = entity {
            latitude = String(entity.lat)
            longitude = String(entity.lon)
        }
        guard let request = urlRequestUsing(lat: latitude, lon: longitude) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<WeatherResponse,Error>) in
            guard let self else { return }
            switch result {
            case .success(let result):
                let name = self.createName(from: result, entity: entity, element: element)
                let temp = Int((result.main.temp - 273.15).rounded())
                let entity = WeatherEntity(
                    id: UUID(),
                    title: name,
                    lat: result.coord.lat,
                    lon: result.coord.lon,
                    temp: temp > 0 ? "+ \(temp)" : "\(temp)",
                    icon: result.weather.first?.icon ?? "",
                    locRu: element?.localNames?.ru ?? entity?.locRu ?? name,
                    locEn: element?.localNames?.en ?? entity?.locEn ?? name
                )
                completion(.success(entity))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }

    private func createName(from result: WeatherResponse, entity: WeatherEntity?, element: GeoLocationResponse?) -> String {
        var name = result.name
        let languageCode = NSLocale.current.languageCode
        if let languageCode = languageCode {
            switch languageCode {
            case "ru":
                name = element?.localNames?.ru ?? entity?.locRu ?? name
            case "en":
                name = element?.localNames?.en ?? entity?.locEn ?? name
            default:
                print("no locale found")
            }
        }
        return name
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

