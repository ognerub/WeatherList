import UIKit

protocol WeatherPresenterProtocol: AnyObject {
    var view: WeatherViewProtocol? { get set }
    var interactor: WeatherListInteractorInputProtocol? { get set }
    var router: WeatherListRouterProtocol? { get set }
    // VIEW -> PRESENTER
    func startUpdateData()
    func retrieveGeoLocationUsing(search: String)
    func addWeatherEntity(_ weatherEntity: WeatherEntity)
    func removeWeatherEntity(_ weatherEntity: WeatherEntity)
}

final class WeatherListPresenter: WeatherPresenterProtocol {
    weak var view: WeatherViewProtocol?
    var interactor: WeatherListInteractorInputProtocol?
    var router: WeatherListRouterProtocol?
    
    func addWeatherEntity(_ weatherEntity: WeatherEntity) {
        interactor?.saveWeatherEntity(weatherEntity)
    }
    
    func startUpdateData() {
        interactor?.retrieveWeatherEntitiesWithRefresh(true)
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
    
    func onError(message: String) {
        view?.showErrorMessage(message)
    }
    
    func didRemoveWeatherEntity(_ weatherEntity: WeatherEntity) {
        interactor?.retrieveWeatherEntitiesWithRefresh(false)
    }
}
