import UIKit

protocol WeatherViewProtocol: AnyObject {
    var presenter: WeatherPresenterProtocol? { get set }
    // PRESENTER -> VIEW
    func showWeather(_ weatherEntities: [WeatherEntity])
    func showErrorMessage(_ message: String)
}

final class WeatherListViewController: UIViewController {
    var presenter: WeatherPresenterProtocol?
    lazy var activityLoader = UIBlockingProgressHUD(viewController: self)
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        return button
    }()
    private var weatherEntities: [WeatherEntity] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var alertController: UIAlertController?

    lazy var search: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = NSLocalizedString("WeatherListViewController.searchController.placeholder", comment: "")
        return search
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        activityLoader.show()
        presenter?.startUpdateData()
    }

    private func setupView() {
        navigationItem.rightBarButtonItem = addButton
        navigationItem.searchController = search
        navigationItem.searchController?.searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: DesignSystemConstants.standartPadding),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -DesignSystemConstants.standartPadding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        tableView.register(WeatherListTableViewCell.self, forCellReuseIdentifier: WeatherListTableViewCell.reuseIdentifier)
    }

    @objc
    func addButtonPressed() {
        activityLoader.show()
        self.presenter?.startUpdateData()
    }
}

extension WeatherListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherListTableViewCell.reuseIdentifier, for: indexPath)
        guard let tableViewCell = cell as? WeatherListTableViewCell else {
            return UITableViewCell()
        }
        let weatherEntity = weatherEntities[indexPath.row]
        let entityTemp = Int((weatherEntity.temp - 273.15).rounded())
        tableViewCell.configureCell(
            with: weatherEntity.title,
            subtitle: entityTemp > 0 ? "+ \(entityTemp)" : "\(entityTemp)"
        )
        return tableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherEntities.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let weatherEntity = weatherEntities[indexPath.row]
            presenter?.removeWeatherEntity(weatherEntity)
        }
    }
}

extension WeatherListViewController: WeatherViewProtocol {
    func showWeather(_ weatherEntities: [WeatherEntity]) {
        self.activityLoader.dismiss()
        self.weatherEntities = weatherEntities
    }

    func showErrorMessage(_ message: String) {
        activityLoader.dismiss()
        if alertController != nil { return }
        self.alertController = UIAlertController(
            title: NSLocalizedString("WeatherListViewController.alertController.errorTitle", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        alertController?.addAction(
            UIAlertAction(
                title: NSLocalizedString("WeatherListViewController.alertController.errorRetry", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let self else { return }
                    activityLoader.show()
                    presenter?.startUpdateData()
                    alertController = nil
                }
            )
        )
        alertController?.addAction(
            UIAlertAction(
                title: NSLocalizedString("WeatherListViewController.alertController.errorDiscard", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let self else { return }
                    alertController = nil
                }
            )
        )
        guard let alertController = alertController else { return }
        present(alertController, animated: true, completion: nil)
    }
}

extension WeatherListViewController: UISearchBarDelegate {
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            if let searchText = searchBar.text {
                activityLoader.show()
                self.presenter?.retrieveGeoLocationUsing(search: searchText)
                self.search.isActive = false
            }
        }
}

