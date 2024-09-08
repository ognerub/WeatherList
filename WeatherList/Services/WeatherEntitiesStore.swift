import Foundation

final class WeatherEntitiesStore {
    private init() {}
    public static let shared = WeatherEntitiesStore()
    public private(set) var weatherEntities: [WeatherEntity] = [
//        WeatherEntity(id: UUID(), title: "Kazan", lat: 55.7823547, lon: 49.1242266, temp: 26.05, icon: "02d"),
        WeatherEntity(id: UUID(), title: "Moscow", lat: 55.7504461, lon: 37.6174943, temp: 24.02, icon: "01d"),
        WeatherEntity(id: UUID(), title: "Krasnodar", lat: 45.0353, lon: 38.9765, temp: 27.97, icon: "10d"),
        WeatherEntity(id: UUID(), title: "Sochi", lat: 43.5855, lon: 39.7231, temp: 28.69, icon: "04d")
//        WeatherEntity(id: UUID(), title: "Klin", lat: 56.3356, lon: 36.7351, temp: 23.16, icon: "01d"),
//        WeatherEntity(id: UUID(), title: "Murmansk", lat: 68.9707, lon: 33.075, temp: 10.55, icon: "03d"),
//        WeatherEntity(id: UUID(), title: "Tiksi", lat: 71.6366, lon: 128.8685, temp: 0.0, icon: "10d"),
//        WeatherEntity(id: UUID(), title: "Vladivostok", lat: 43.1151, lon: 131.8856, temp: 22.54, icon: "01d")
    ]

    func reloadWeatherEntities(_ weatherEntities: [WeatherEntity]) {
        self.weatherEntities = weatherEntities
    }

    func addWeatherEntity(_ weatherEntity: WeatherEntity) {
        weatherEntities.insert(weatherEntity, at: 0)
    }

    func removeWeatherEntity(_ weatherEntity: WeatherEntity) {
        if let index = weatherEntities.firstIndex(where: { $0.id == weatherEntity.id }) {
            weatherEntities.remove(at: index)
        }
    }
}
