import UIKit

protocol WeatherPresenterProtocol: AnyObject {
    var view: WeatherListViewProtocol? { get set }
    var interactor: WeatherListInteractorInputProtocol? { get set }
    var router: WeatherListRouterProtocol? { get set }
    // VIEW -> PRESENTER
    func showTodoDetail(_ weatherEntity: WeatherEntity)
    func addWeatherEntity(_ weatherEntity: WeatherEntity)
    func startUpdateDataWithRefresh(_ bool: Bool)
    func retrieveGeoLocationUsing(search: String)
    func removeWeatherEntity(_ weatherEntity: WeatherEntity)
}

final class WeatherListPresenter: WeatherPresenterProtocol {
    weak var view: WeatherListViewProtocol?
    var interactor: WeatherListInteractorInputProtocol?
    var router: WeatherListRouterProtocol?

    func showTodoDetail(_ entity: WeatherEntity) {
        guard let view = view else { return }
        router?.presentWeatherDetailScreen(from: view, for: entity)
    }

    func addWeatherEntity(_ weatherEntity: WeatherEntity) {
        interactor?.saveWeatherEntity(weatherEntity)
    }
    
    func startUpdateDataWithRefresh(_ bool: Bool) {
        interactor?.retrieveWeatherEntitiesWithRefresh(bool)
    }

    func retrieveGeoLocationUsing(search: String) {
        interactor?.retrieveGeoLocationUsing(search: search)
    }

    func removeWeatherEntity(_ weatherEntity: WeatherEntity) {
        interactor?.deleteWeatherEntity(weatherEntity)
    }
}

extension WeatherListPresenter: WeatherListInteractorOutputProtocol {
    func didAddWeatherEntity(_ weatherEntity: WeatherEntity) {
        interactor?.retrieveWeatherEntitiesWithRefresh(false)
    }
    
    func didRetrieveWeatherEntities(_ weatherEntities: [WeatherEntity]) {
        view?.showWeather(weatherEntities)
    }
    
    func showAlert(message: String) {
        view?.showMessage(message)
    }
    
    func didRemoveWeatherEntity(_ weatherEntity: WeatherEntity) {
        interactor?.retrieveWeatherEntitiesWithRefresh(false)
    }
}
