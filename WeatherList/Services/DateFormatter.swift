//
//  DateFormatter.swift
//  WeatherList
//
//  Created by Alexander Ognerubov on 11.09.2024.
//

import Foundation

final class DateFormatterService {
    private let inputDateFormatter = DateFormatter()
    private let outputDateFormatter = DateFormatter()

    init() {
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        outputDateFormatter.dateFormat = "dd MMMM HH:mm"
    }

    func getString(from string: String) -> String {
        guard let date = inputDateFormatter.date(from: string) else { return "" }
        return outputDateFormatter.string(from: date)
    }
}
