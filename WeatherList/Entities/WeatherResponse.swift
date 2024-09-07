import Foundation

struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: WeatherMainData
    let coord: WeatherCoordData
    let name: String
}

struct Weather: Codable {
    let main: String
    let description: String?
    let icon: String
}

struct WeatherMainData: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
}

struct WeatherCoordData: Codable {
    let lon: Double
    let lat: Double
}


