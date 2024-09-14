import Foundation
import RealmSwift

struct WeatherEntity {
    let id: UUID
    let title: String
    let lat: Double
    let lon: Double
    let temp: Double
    let icon: String
}

class RealmWeatherEntity: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var lat: Double
    @Persisted var lon: Double
    @Persisted var temp: Double
    @Persisted var icon: String

    convenience init(title: String, lat: Double, lon: Double, temp: Double, icon: String) {
        self.init()
        self.title = title
        self.lat = lat
        self.lon = lon
        self.temp = temp
        self.icon = icon
    }
}
