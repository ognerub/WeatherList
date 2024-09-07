import UIKit

protocol WeatherListRouterProtocol: AnyObject {
    static func createWeatherListModule() -> UIViewController
}

final class WeatherListRouter: WeatherListRouterProtocol {
    static func createWeatherListModule() -> UIViewController {
        let navController = UINavigationController(rootViewController: WeatherListViewController())
        guard let weatherListViewController = navController.topViewController as? WeatherListViewController else { fatalError("Invalid View Controller") }
        let presenter: WeatherPresenterProtocol & WeatherListInteractorOutputProtocol = WeatherListPresenter()
        let interactor: WeatherListInteractorInputProtocol = WeatherListInteractor()
        let router = WeatherListRouter()
        weatherListViewController.presenter = presenter
        presenter.view = weatherListViewController
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        return navController
    }
}
