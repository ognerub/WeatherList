//
//  ForecastSevice.swift
//  WeatherList
//
//  Created by Alexander Ognerubov on 09.09.2024.
//

import Foundation

protocol ForecastServiceProtocol: AnyObject {
    func fetchGeoLocationUsing(lat: String, lon: String, completion: @escaping (Result<ForecastEntity, Error>) -> Void)
}

final class ForecastService: ForecastServiceProtocol {

    private let urlSession: URLSession
    private let builder: URLRequestBuilderProtocol
    private let storage = WeatherEntitiesStore.shared
    private var currentTask: URLSessionTask?

    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilderProtocol
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }

    func fetchGeoLocationUsing(lat: String, lon: String, completion: @escaping (Result<ForecastEntity, Error>) -> Void) {
        if currentTask != nil {
            completion(.failure(NetworkError.urlSessionError))
            return
        } else {
            currentTask?.cancel()
        }
        guard let request = urlRequestUsing(lat: lat, lon: lon) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ForecastResponse,Error>) in
            guard let self else { return }
            self.currentTask = nil
            switch result {
            case .success(let result):
                let forecastEntity = ForecastEntity(
                    id: UUID(),
                    title: result.city.name,
                    forecast: result.list.compactMap { list in
                        DayForecast(
                            temp: (list.main.temp - 273.15).rounded(),
                            date: list.dtTxt
                        )
                    }
                )
                completion(.success(forecastEntity))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        currentTask?.resume()
    }
}

private extension ForecastService {
    func urlRequestUsing(lat: String, lon: String) -> URLRequest? {
        let path: String = NetworkConstants.forecastPath
        return builder.makeWeatherHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURLString: NetworkConstants.baseUrl,
            queryItems: [
                URLQueryItem(name: "lat", value: lat),
                URLQueryItem(name: "lon", value: lon),
                URLQueryItem(name: "appid", value: NetworkConstants.apiKey)
            ]
        )
    }
}

