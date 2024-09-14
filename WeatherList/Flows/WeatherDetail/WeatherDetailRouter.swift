import UIKit

protocol WeatherDetailRouterProtocol: AnyObject {
    static func createWeatherDetailRouterModule(with weather: WeatherEntity) -> UIViewController
    // PRESENTER -> ROUTER
    func navigateBackToListViewController(from view: WeatherDetailViewProtocol)
}

class WeatherDetailRouter: WeatherDetailRouterProtocol {
    func navigateBackToListViewController(from view: WeatherDetailViewProtocol) {
        guard let viewVC = view as? UIViewController else {
            fatalError("Invalid view protocol type")
        }
        viewVC.navigationController?.popViewController(animated: true)
    }

    static func createWeatherDetailRouterModule(with weather: WeatherEntity) -> UIViewController {
        let weatherDetailVC = WeatherDetailViewController(nibName: nil, bundle: nil)
        let presenter: WeatherDetailPresenter & WeatherDetailInteractorOutputProtocol = WeatherDetailPresenter()
        weatherDetailVC.presenter = presenter
        presenter.view = weatherDetailVC
        let interactor: WeatherDetailInteractorInputProtocol = WeatherDetailInteractor(weatherEntitiesStore: WeatherEntitiesStore())
        interactor.weatherItem = weather
        interactor.presenter = presenter
        presenter.interactor = interactor
        let router: WeatherDetailRouterProtocol = WeatherDetailRouter()
        presenter.router = router
        return weatherDetailVC
    }
}
