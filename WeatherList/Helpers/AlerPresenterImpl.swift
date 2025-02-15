//
//  AlerPresenterImpl.swift
//  WeatherList
//
//  Created by Alexander Ognerubov on 18.09.2024.
//

import UIKit

protocol AlertPresenterProtocol: AnyObject {
    func show(with alertModel: AlertModel, style: UIAlertAction.Style)
}

final class AlertPresenterImpl {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

}

extension AlertPresenterImpl: AlertPresenterProtocol {
    func show(with alertModel: AlertModel, style: UIAlertAction.Style) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let firstAction = UIAlertAction(
            title: alertModel.firstButton,
            style: style) { _ in
            alertModel.firstCompletion()
        }
        alert.addAction(firstAction)
        if alertModel.secondButton != nil {
            let secondAction = UIAlertAction(
                title: alertModel.secondButton,
                style: .default) { _ in
                    alertModel.secondCompletion()
                }
            alert.addAction(secondAction)
        }
        viewController?.present(alert, animated: true)
    }
}

