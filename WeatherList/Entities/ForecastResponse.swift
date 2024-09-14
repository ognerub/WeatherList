import Foundation

struct ForecastResponse: Codable {
    let cod: String
    let message, cnt: Int
    let list: [ForecastList]
    let city: ForecastCity
}

struct ForecastCity: Codable {
    let id: Int
    let name: String
    let coord: ForecastCoord
    let country: String
    let population, timezone, sunrise, sunset: Int
}

struct ForecastCoord: Codable {
    let lat, lon: Double
}

struct ForecastList: Codable {
    let dt: Int
    let main: MainClass
    let weather: [ForecastWeather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int?
    let pop: Double
    let sys: Sys
    let dtTxt: String
    let rain: Rain?
}

struct MainClass: Codable {
    let temp, tempMin, tempMax: Double
    let feelsLike: Double?
    let pressure, seaLevel, grndLevel, humidity: Int
    let tempKf: Double
}

struct Clouds: Codable {
    let all: Int
}

struct Rain: Codable {
    let the3H: Double
    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

struct Sys: Codable {
    let pod: Pod
}

enum Pod: String, Codable {
    case d = "d"
    case n = "n"
}

struct ForecastWeather: Codable {
    let id: Int
    let main: MainEnum
    let description, icon: String
}

enum MainEnum: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
    case snow = "Snow"
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double
}

