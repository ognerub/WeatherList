import Foundation

typealias GeoLocation = [GeoLocationResponse]

struct GeoLocationResponse: Codable {
    let name: String
    let localNames: LocalNames
    let lat: Double
    let lon: Double
}

struct LocalNames: Codable {
    let en: String?
    let ru: String?
}
