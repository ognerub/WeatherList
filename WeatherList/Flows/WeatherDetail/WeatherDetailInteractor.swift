import Foundation

protocol WeatherDetailInteractorInputProtocol: AnyObject {
    var presenter: WeatherDetailInteractorOutputProtocol? { get set }
    var weatherItem: WeatherEntity? { get set }
    // PRESENTER -> INTERACTOR
    func deleteWeather()
    func getForecastFor(lat: String, lon: String)
}

protocol WeatherDetailInteractorOutputProtocol: AnyObject {
    // INTERACTOR -> PRESENTER
    func didDeleteWeather()
    func didRetrieveForecasts(_ forecasts: [[DayForecast]])
    func showAlert(message: String)
}

class WeatherDetailInteractor: WeatherDetailInteractorInputProtocol {
    var weatherItem: WeatherEntity?
    weak var presenter: WeatherDetailInteractorOutputProtocol?
    lazy var forecastService = ForecastService(urlSession: urlSession, builder: urlBuilder)
    private let weatherEntitiesStore: WeatherEntitiesStoreProtocol
    private let urlSession = URLSession.shared
    private let urlBuilder = URLRequestBuilder()
    private let dateFormatter = DateFormatterService()

    init( weatherEntitiesStore: WeatherEntitiesStoreProtocol) {
        self.weatherEntitiesStore = weatherEntitiesStore
    }

    func deleteWeather() {
        guard let weatherItem = weatherItem else { return }
        weatherEntitiesStore.removeWeatherEntity(weatherItem)
        presenter?.didDeleteWeather()
    }

    func getForecastFor(lat: String, lon: String) {
        forecastService.fetchGeoLocationUsing(lat: lat, lon: lon, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let result):
                let forecasts = self.createDayForecasts(from: result)
                self.presenter?.didRetrieveForecasts(forecasts)
            case .failure(let error):
                self.presenter?.showAlert(message: NSLocalizedString("WeatherListInteractor.alertController.\(error)", comment: ""))
            }
        })
    }

    private func createDayForecasts(from forecast: ForecastEntity) -> [[DayForecast]] {
        var groups = [[DayForecast]]()
        var group = [DayForecast]()
        var previous: String?
        forecast.forecast.enumerated().forEach { (index, value) in
            let element = forecast.forecast[index]
            let current = String(dateFormatter.getString(from: element.date).prefix(2))
            if previous == nil {
                previous = current
            }
            if current == previous {
                group.append(element)
            } else {
                previous = current
                groups.append(group)
                group = []
                group.append(element)
            }
        }
        groups.append(group)
        return groups
    }
}
