import Foundation

struct ForecastEntity {
    let id: UUID
    let title: String
    let forecast: [DayForecast]
}

struct DayForecast {
    let temp: String
    let date: String
    let icon: String
}

