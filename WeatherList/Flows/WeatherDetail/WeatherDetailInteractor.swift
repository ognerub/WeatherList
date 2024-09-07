import Foundation

protocol WeatherDetailInteractorInputProtocol: AnyObject {
    var presenter: WeatherDetailInteractorOutputProtocol? { get set }
    var weatherItem: WeatherEntity? { get set }
    // PRESENTER -> INTERACTOR
    func deleteWeather()
}

protocol WeatherDetailInteractorOutputProtocol: AnyObject {
    // INTERACTOR -> PRESENTER
    func didDeleteWeather()
}

class WeatherDetailInteractor: WeatherDetailInteractorInputProtocol {
    weak var presenter: WeatherDetailInteractorOutputProtocol?
    var weatherStore = WeatherEntitiesStore.shared
    var weatherItem: WeatherEntity?

    func deleteWeather() {
        guard let weatherItem = weatherItem else { return }
        weatherStore.removeWeatherEntity(weatherItem)
        presenter?.didDeleteWeather()
    }
}
