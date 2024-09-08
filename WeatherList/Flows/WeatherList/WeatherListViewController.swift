import UIKit
import Kingfisher

protocol WeatherListViewProtocol: AnyObject {
    var presenter: WeatherPresenterProtocol? { get set }
    // PRESENTER -> VIEW
    func showWeather(_ weatherEntities: [WeatherEntity])
    func showMessage(_ message: String)
}

final class WeatherListViewController: UIViewController {
    var presenter: WeatherPresenterProtocol?
    var activityLoader: UIBlockingProgressHUD?
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(addButtonPressed))
        return button
    }()
    lazy var search: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = NSLocalizedString("WeatherListViewController.searchController.placeholder", comment: "")
        return search
    }()
    private var weatherEntities: [WeatherEntity] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var alertController: UIAlertController?
    private var isFirstStart = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        activityLoader = UIBlockingProgressHUD(viewController: self)
        setupView()
        activityLoader?.show()
        presenter?.startUpdateDataWithRefresh(false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirstStart {
            presenter?.startUpdateDataWithRefresh(false)
        }
        isFirstStart = false
    }

    private func setupView() {
        navigationItem.rightBarButtonItem = addButton
        navigationItem.searchController = search
        navigationItem.searchController?.searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(WeatherListTableViewCell.self, forCellReuseIdentifier: WeatherListTableViewCell.reuseIdentifier)
    }

    @objc
    func addButtonPressed() {
        activityLoader?.show()
        self.presenter?.startUpdateDataWithRefresh(true)
    }
}

extension WeatherListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherEntities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCellAt(indexPath: indexPath)
    }

    private func configureCellAt(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherListTableViewCell.reuseIdentifier, for: indexPath)
        guard let tableViewCell = cell as? WeatherListTableViewCell else {
            return UITableViewCell()
        }
        let weatherEntity = weatherEntities[indexPath.row]
        let entityTemp = Int(weatherEntity.temp)
        tableViewCell.configureCell(
            with: weatherEntity.title,
            subtitle: entityTemp > 0 ? "+ \(entityTemp)" : "\(entityTemp)"
        )
        downloadImageFor(cell: tableViewCell, at: indexPath)
        tableViewCell.selectionStyle = .none
        return tableViewCell
    }
}

extension WeatherListViewController: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        DesignSystemConstants.weatherCellSize
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = weatherEntities[indexPath.row]
        presenter?.showTodoDetail(entity)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let weatherEntity = weatherEntities[indexPath.row]
            presenter?.removeWeatherEntity(weatherEntity)
        }
    }
}

extension WeatherListViewController: WeatherListViewProtocol {
    func showWeather(_ weatherEntities: [WeatherEntity]) {
        activityLoader?.dismiss()
        self.weatherEntities = weatherEntities
    }

    func showMessage(_ message: String) {
        activityLoader?.dismiss()
        if alertController != nil { return }
        self.alertController = UIAlertController(
            title: NSLocalizedString("WeatherListViewController.alertController.title", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        alertController?.addAction(
            UIAlertAction(
                title: NSLocalizedString("WeatherListViewController.alertController.errorClose", comment: ""),
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
            activityLoader?.show()
            self.presenter?.retrieveGeoLocationUsing(search: searchText)
            self.search.isActive = false
        }
    }
}

private extension WeatherListViewController {
    func downloadImageFor(cell: WeatherListTableViewCell, at indexPath: IndexPath) {
        let url = "\(NetworkConstants.imageUrl)\(weatherEntities[indexPath.row].icon)@2x.png"
        let processor = DownsamplingImageProcessor(size: CGSize(width: DesignSystemConstants.weatherCellSize, height: DesignSystemConstants.weatherCellSize))
        cell.weatherImageView.kf.indicatorType = .activity
        cell.weatherImageView.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(),
            options: [
                .processor(processor)
            ]
        ) { result in
            switch result {
            case .success(_):
                cell.weatherImageView.contentMode = .scaleAspectFill
            case .failure(_):
                cell.weatherImageView.image = UIImage(named: DesignSystemConstants.noIconImage)
            }
        }
    }
}

