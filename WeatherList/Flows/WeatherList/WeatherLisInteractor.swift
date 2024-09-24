import Foundation
import RealmSwift

protocol WeatherListInteractorInputProtocol: AnyObject {
    var presenter: WeatherListInteractorOutputProtocol? { get set }
    // PRESENTER -> INTERACTOR
    func retrieveWeatherEntitiesWithRefresh(_ isRefresh: Bool)
    func retrieveGeoLocationUsing(search: String)
    func saveWeatherEntity(_ weatherEntity: WeatherEntity)
    func deleteWeatherEntity(_ weatherEntity: WeatherEntity)
}

protocol WeatherListInteractorOutputProtocol: AnyObject {
    // INTERACTOR -> PRESENTER
    func didAddWeatherEntity(_ weatherEntity: WeatherEntity)
    func didRemoveWeatherEntity(_ weatherEntity: WeatherEntity)
    func didRetrieveWeatherEntities(_ weatherEntities: [WeatherEntity])
    func showAlert(message: String)
}

final class WeatherListInteractor: WeatherListInteractorInputProtocol {
    lazy var geoLocationService = GeoLocationService(urlSession: urlSession, builder: urlBuilder)
    lazy var weatherService = WeatherService(urlSession: urlSession, builder: urlBuilder)
    weak var presenter: WeatherListInteractorOutputProtocol?
    private let weatherEntitiesStore: WeatherEntitiesStoreProtocol
    private let urlSession = URLSession.shared
    private let urlBuilder = URLRequestBuilder()
    private var weatherEntities: [WeatherEntity] {
        return weatherEntitiesStore.getEntitiesFromRealm().reversed()
    }

    init(weatherEntitiesStore: WeatherEntitiesStoreProtocol) {
        self.weatherEntitiesStore = weatherEntitiesStore
    }

    func retrieveWeatherEntitiesWithRefresh(_ isRefresh: Bool) {
        if isRefresh {
            weatherService.fetchWeatherFor(entities: weatherEntities, completion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let result):
                    self.weatherEntitiesStore.reloadWeatherEntities(result)
                    self.presenter?.didRetrieveWeatherEntities(self.weatherEntities)
                    self.presenter?.showAlert(message: NSLocalizedString("WeatherListInteractor.alertController.successRefresh", comment: ""))
                case .failure(_):
                    self.presenter?.showAlert(message: NSLocalizedString("WeatherListInteractor.alertController.errorRefresh", comment: ""))
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
                    self.fetchSearched(element: element)
                } else {
                    self.presenter?.showAlert(message: NSLocalizedString("WeatherListInteractor.alertController.errorName", comment: ""))
                }
            case .failure(let error):
                self.presenter?.showAlert(message: NSLocalizedString("WeatherListInteractor.alertController.\(error)", comment: ""))
            }
        }
    }

    private func fetchSearched(element: GeoLocationResponse) {
        weatherService.fetchWeatherFor(element: element) { result in
            switch result {
            case .success(let entity):
                self.saveWeatherEntity(entity)
            case .failure(_):
                self.presenter?.showAlert(message: NSLocalizedString("WeatherListInteractor.alertController.errorNetwork", comment: ""))
            }
        }
    }
}
