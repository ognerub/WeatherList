import UIKit

protocol WeatherListRouterProtocol: AnyObject {
    static func createWeatherListModule() -> UIViewController
    // PRESENTER -> ROUTER
    func presentWeatherDetailScreen(from view: WeatherListViewProtocol, for weatherEntity: WeatherEntity)
}

final class WeatherListRouter: WeatherListRouterProtocol {
    static func createWeatherListModule() -> UIViewController {
        let navController = UINavigationController(rootViewController: WeatherListViewController())
        guard let weatherListViewController = navController.topViewController as? WeatherListViewController else { fatalError("Invalid View Controller") }
        let presenter: WeatherPresenterProtocol & WeatherListInteractorOutputProtocol = WeatherListPresenter()
        let interactor: WeatherListInteractorInputProtocol = WeatherListInteractor(weatherEntitiesStore: WeatherEntitiesStore())
        let router = WeatherListRouter()
        weatherListViewController.presenter = presenter
        presenter.view = weatherListViewController
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        return navController
    }

    func presentWeatherDetailScreen(from view: WeatherListViewProtocol, for weatherEntity: WeatherEntity) {
        let weatherDetailVC = WeatherDetailRouter.createWeatherDetailRouterModule(with: weatherEntity)
        guard let viewVC = view as? UIViewController else {
            fatalError("Invalid View Protocol type")
        }
        viewVC.navigationController?.pushViewController(weatherDetailVC, animated: true)
    }
}
