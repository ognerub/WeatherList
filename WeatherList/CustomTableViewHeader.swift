//
//  CustomTableViewHeader.swift
//  WeatherList
//
//  Created by Alexander Ognerubov on 18.09.2024.
//

import UIKit

final class CustomTableViewHeader: UITableViewHeaderFooterView {
    static let reuseIdentifier = "CustomTableViewHeader"

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: DesignSystemConstants.textTitleSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureHeader(with title: String) {
        titleLabel.text = title
    }

    private func configureUI() {
        self.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
