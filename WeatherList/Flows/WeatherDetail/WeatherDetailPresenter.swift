import UIKit

protocol WeatherDetailPresenterProtocol: AnyObject {
    var view: WeatherDetailViewProtocol? { get set }
    var interactor: WeatherDetailInteractorInputProtocol? { get set }
    var router: WeatherDetailRouterProtocol? { get set }
    // VIEW -> PRESENTER
    func viewDidLoad()
    func deleteWeather()
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
}
