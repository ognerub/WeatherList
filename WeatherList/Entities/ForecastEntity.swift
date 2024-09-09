import Foundation

struct ForecastEntity {
    let id: UUID
    let title: String
    let forecast: [DayForecast]
}

struct DayForecast {
    let temp: Double
    let date: String
    let icon: String
}

