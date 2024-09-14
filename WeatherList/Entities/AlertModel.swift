//
//  AlertModel.swift
//  WeatherList
//
//  Created by Alexander Ognerubov on 18.09.2024.
//

import Foundation

struct AlertModel {
    var title: String
    let message: String
    let firstButton: String
    let secondButton: String?
    let firstCompletion: () -> Void
    let secondCompletion: () -> Void?
}
