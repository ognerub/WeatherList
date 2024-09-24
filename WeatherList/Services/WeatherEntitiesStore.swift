import Foundation
import RealmSwift

protocol WeatherEntitiesStoreProtocol: AnyObject {
    func reloadWeatherEntities(_ entities: [WeatherEntity])
    func addWeatherEntity(_ entity: WeatherEntity)
    func removeWeatherEntity(_ entity: WeatherEntity)
    func getEntitiesFromRealm() -> [WeatherEntity]
}

final class WeatherEntitiesStore: WeatherEntitiesStoreProtocol {
    @ObservedResults(RealmWeatherEntity.self) var realmWeatherEntities

    func reloadWeatherEntities(_ entities: [WeatherEntity]) {
        deleteAllFromRealm()
        writeToRealm(entites: entities.reversed())
    }

    func addWeatherEntity(_ entity: WeatherEntity) {
        writeToRealm(entity: entity)
    }

    func removeWeatherEntity(_ entity: WeatherEntity) {
        deleteFromRealm(entity: entity)
    }

    func getEntitiesFromRealm() -> [WeatherEntity] {
        if checkIsRealmEmpty() {
            return []
        } else {
            return self.realmWeatherEntities.compactMap { value in
                let weatherEntity = WeatherEntity(
                    id: UUID(),
                    title: value.title,
                    lat: value.lat,
                    lon: value.lon,
                    temp: value.temp,
                    icon: value.icon,
                    locRu: value.locRu,
                    locEn: value.locEn
                )
                return weatherEntity
            }
        }
    }

    private func writeToRealm(entites: [WeatherEntity]) {
        entites.forEach { value in
            writeToRealm(entity: value)
        }
    }

    private func writeToRealm(entity: WeatherEntity) {
        do {
            let realm = try Realm()
            try realm.write {
                let realmWeatherEntity = createRealmWeatherEntity(from: entity)
                realm.add(realmWeatherEntity)
            }
        } catch {
            print("error write entity to Realm: \(error)")
        }
    }

    private func deleteAllFromRealm() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Realm delete all error: \(error)")
        }
    }

    private func deleteFromRealm(entity: WeatherEntity) {
        do {
            let realm = try Realm()
            let realmWeatherEntities = realm.objects(RealmWeatherEntity.self)
            let entityToDelete = realmWeatherEntities.first(where: { $0.lat == entity.lat && $0.lon == entity.lon } )
            guard let entityToDelete = entityToDelete else { return }
            try realm.write {
                realm.delete(entityToDelete)
            }
        } catch {
            print("Realm delete \(entity.title) error: \(error)")
        }
    }

    private func checkIsRealmEmpty() -> Bool {
        var isRealmEmpty = true
        do {
            let realm = try Realm()
            let realmWeatherEntities = realm.objects(RealmWeatherEntity.self)
            if realmWeatherEntities.count > 0 {
                isRealmEmpty = false
            }
        } catch {
            print("Realm read error: \(error)")
        }
        return isRealmEmpty
    }

    private func createRealmWeatherEntity(from entity: WeatherEntity) -> RealmWeatherEntity {
        return RealmWeatherEntity(
            title: entity.title,
            lat: entity.lat,
            lon: entity.lon,
            temp: entity.temp,
            icon: entity.icon,
            locRu: entity.locRu,
            locEn: entity.locEn
        )
    }
}
