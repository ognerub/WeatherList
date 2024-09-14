import UIKit

protocol WeatherDetailPresenterProtocol: AnyObject {
    var view: WeatherDetailViewProtocol? { get set }
    var interactor: WeatherDetailInteractorInputProtocol? { get set }
    var router: WeatherDetailRouterProtocol? { get set }
    // VIEW -> PRESENTER
    func viewDidLoad()
    func deleteWeather()
    func retrieveForecastUsing(lat: String, lon: String)
}

class WeatherDetailPresenter: WeatherDetailPresenterProtocol {
    weak var view: WeatherDetailViewProtocol?
    var router: WeatherDetailRouterProtocol?
    var interactor: WeatherDetailInteractorInputProtocol?

    func viewDidLoad() {
        if let weatherItem = interactor?.weatherItem {
            view?.showWeather(weatherItem)
        }
    }

    func retrieveForecastUsing(lat: String, lon: String) {
        interactor?.getForecastFor(lat: lat, lon: lon)
    }

    func deleteWeather() {
        interactor?.deleteWeather()
    }
}

extension WeatherDetailPresenter: WeatherDetailInteractorOutputProtocol {
    func didDeleteWeather() {
        if let view = view {
            router?.navigateBackToListViewController(from: view)
        }
    }

    func showAlert(message: String) {
        view?.showMessage(message)
    }

    func didRetrieveForecasts(_ forecasts: [[DayForecast]]) {
        view?.showForecasts(forecasts)
    }
}
