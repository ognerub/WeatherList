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
    func didRetrieveForecast(_ forecastEntity: ForecastEntity)
}

class WeatherDetailInteractor: WeatherDetailInteractorInputProtocol {
    var weatherStore = WeatherEntitiesStore.shared
    var weatherItem: WeatherEntity?
    weak var presenter: WeatherDetailInteractorOutputProtocol?
    lazy var forecastService = ForecastService(urlSession: urlSession, builder: urlBuilder)
    private let urlSession = URLSession.shared
    private let urlBuilder = URLRequestBuilder()

    func deleteWeather() {
        guard let weatherItem = weatherItem else { return }
        weatherStore.removeWeatherEntity(weatherItem)
        presenter?.didDeleteWeather()
    }

    func getForecastFor(lat: String, lon: String) {
        forecastService.fetchGeoLocationUsing(lat: lat, lon: lon, completion: { result in
            switch result {
            case .success(let result):
                self.presenter?.didRetrieveForecast(result)
            case .failure(let error):
                print("error \(error)")
            }
        })
    }
}
