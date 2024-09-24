import Foundation
import RealmSwift

struct WeatherEntity {
    let id: UUID
    let title: String
    let lat: Double
    let lon: Double
    let temp: String
    let icon: String
    let locRu: String
    let locEn: String
}

class RealmWeatherEntity: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var lat: Double
    @Persisted var lon: Double
    @Persisted var temp: String
    @Persisted var icon: String
    @Persisted var locRu: String
    @Persisted var locEn: String

    convenience init(title: String, lat: Double, lon: Double, temp: String, icon: String, locRu: String, locEn: String) {
        self.init()
        self.title = title
        self.lat = lat
        self.lon = lon
        self.temp = temp
        self.icon = icon
        self.locRu = locRu
        self.locEn = locEn
    }
}
