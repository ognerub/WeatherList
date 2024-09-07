import Foundation

final class WeatherEntitiesStore {
    private init() {}
    public static let shared = WeatherEntitiesStore()

    public private(set) var weatherEntities: [WeatherEntity] = [
        WeatherEntity(id: UUID(), title: "Kazan", lat: 55.7823547, lon: 49.1242266, temp: 300.0, icon: ""),
        WeatherEntity(id: UUID(), title: "Moscow", lat: 55.7504461, lon: 37.6174943, temp: 280.0, icon: ""),
        WeatherEntity(id: UUID(), title: "Saint-Petersburg", lat: 59.938732, lon: 30.316229, temp: 260.0, icon: "")
    ]

    func reloadWeatherEntities(_ weatherEntities: [WeatherEntity]) {
        self.weatherEntities = weatherEntities
    }

    func addWeatherEntity(_ weatherEntity: WeatherEntity) {
        weatherEntities.append(weatherEntity)
    }

    func removeWeatherEntity(_ weatherEntity: WeatherEntity) {
        if let index = weatherEntities.firstIndex(where: { $0.id == weatherEntity.id }) {
            weatherEntities.remove(at: index)
        }
    }
}
