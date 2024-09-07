import Foundation

protocol WeatherListInteractorInputProtocol: AnyObject {
    var presenter: WeatherListInteractorOutputProtocol? { get set }
    // PRESENTER -> INTERACTOR
    func retrieveWeatherEntitiesWithRefresh(_ bool: Bool)
    func retrieveGeoLocationUsing(search: String)
    func saveWeatherEntity(_ weatherEntity: WeatherEntity)
    func deleteWeatherEntity(_ weatherEntity: WeatherEntity)
}

protocol WeatherListInteractorOutputProtocol: AnyObject {
    // INTERACTOR -> PRESENTER
    func didAddWeatherEntity(_ weatherEntity: WeatherEntity)
    func didRemoveWeatherEntity(_ weatherEntity: WeatherEntity)
    func didRetrieveWeatherEntities(_ weatherEntities: [WeatherEntity])
    func onError(message: String)
}

final class WeatherListInteractor: WeatherListInteractorInputProtocol {
    lazy var geoLocationService = GeoLocationService(urlSession: urlSession, builder: urlBuilder)
    lazy var weatherService = WeatherService(urlSession: urlSession, builder: urlBuilder)
    weak var presenter: WeatherListInteractorOutputProtocol?
    private let urlSession = URLSession.shared
    private let urlBuilder = URLRequestBuilder()
    private var weatherEntitiesStore = WeatherEntitiesStore.shared
    private var weatherEntities: [WeatherEntity] {
        return weatherEntitiesStore.weatherEntities
    }

    func retrieveWeatherEntitiesWithRefresh(_ bool: Bool) {
        if bool {
            weatherService.fetchWeatherFor(entities: weatherEntities, completion: { result in
                switch result {
                case .success(let result):
                    if result.count > 0 {
                        self.weatherEntitiesStore.reloadWeatherEntities(result)
                        self.presenter?.didRetrieveWeatherEntities(self.weatherEntities)
                    }
                case .failure(let error):
                    self.presenter?.didRetrieveWeatherEntities(self.weatherEntities)
                    self.presenter?.onError(message: "Error while fetch weather \(error.localizedDescription)")
                }
            })
        } else {
            self.presenter?.didRetrieveWeatherEntities(self.weatherEntities)
        }
    }

    func saveWeatherEntity(_ weatherEntity: WeatherEntity) {
        weatherEntitiesStore.addWeatherEntity(weatherEntity)
        presenter?.didAddWeatherEntity(weatherEntity)
    }

    func deleteWeatherEntity(_ weatherEntity: WeatherEntity) {
        weatherEntitiesStore.removeWeatherEntity(weatherEntity)
        presenter?.didRemoveWeatherEntity(weatherEntity)
    }

    func retrieveGeoLocationUsing(search: String) {
        geoLocationService.fetchGeoLocationUsing(search: search) { result in
            switch result {
            case .success(let result):
                if result.count > 0 {
                    let element = result[0]
                    let lat = String(element.lat)
                    let lon = String(element.lon)
                    self.fetchSearched(lat: lat, lon: lon)
                } else {
                    self.presenter?.onError(message: "Ошибка в названии населенного пункта, попробуйте еще раз")
                }
            case .failure(let error):
                self.presenter?.onError(message: "Ошибка сетевого запроса \(error.localizedDescription)")
            }
        }
    }

    private func fetchSearched(lat: String, lon: String) {
        weatherService.fetchWeatherFor(lat: lat, lon: lon) { result in
            switch result {
            case .success(let entity):
                self.saveWeatherEntity(entity)
            case .failure(_):
                return
            }
        }
    }
}
