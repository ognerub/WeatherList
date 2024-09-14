import UIKit

protocol WeatherListViewProtocol: AnyObject {
    var presenter: WeatherPresenterProtocol? { get set }
    // PRESENTER -> VIEW
    func showWeather(_ weatherEntities: [WeatherEntity])
    func showMessage(_ message: String)
}

final class WeatherListViewController: UIViewController {
    // MARK: Properties
    var presenter: WeatherPresenterProtocol?
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy var updateButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateButtonPressed))
        return button
    }()
    @objc lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        return button
    }()
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = NSLocalizedString("WeatherListViewController.searchController.placeholder", comment: "")
        return search
    }()
    lazy var verticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoImageView,infoLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = DesignSystemConstants.standartPadding
        stack.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addButtonPressed))
        stack.isUserInteractionEnabled = true
        stack.addGestureRecognizer(tapGesture)
        return stack
    }()
    lazy var infoImageView: UIImageView = {
        let image = UIImage(systemName: "building.2.crop.circle.fill")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(named: DesignSystemConstants.customOrangeColor)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("WeatherListViewController.titleLabel.infoText", comment: "")
        label.textColor = UIColor(named: DesignSystemConstants.customOrangeColor)
        label.font = UIFont.systemFont(ofSize: DesignSystemConstants.textTitleSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var alertController: UIAlertController?
    private var alertPresenter: AlertPresenterProtocol?
    private var activityLoader: UIBlockingProgressHUD?
    private var weatherEntities: [WeatherEntity] = [] {
        didSet {
            if weatherEntities.isEmpty {
                addInfoStack()
                updateButton.isEnabled = false
            } else {
                verticalStack.removeFromSuperview()
                updateButton.isEnabled = true
            }
            tableView.reloadData()
        }
    }
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        activityLoader = UIBlockingProgressHUD(viewController: self)
        alertPresenter = AlertPresenterImpl(viewController: self)
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityLoader?.show()
        presenter?.startUpdateDataWithRefresh(false)
    }
    // MARK: Methods
    private func addInfoStack() {
        view.addSubview(verticalStack)
        NSLayoutConstraint.activate([
            verticalStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoImageView.heightAnchor.constraint(equalToConstant: DesignSystemConstants.weatherCellSize)
        ])
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = updateButton
        navigationItem.leftBarButtonItem = addButton
        navigationItem.searchController = searchController
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
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
    }

    @objc func updateButtonPressed() {
        activityLoader?.show()
        self.presenter?.startUpdateDataWithRefresh(true)
    }

    @objc func addButtonPressed() {
        searchController.searchBar.becomeFirstResponder()
    }
}

// MARK: - UITableViewDataSource
extension WeatherListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherEntities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCellAt(indexPath: indexPath)
    }

    private func configureCellAt(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath)
        guard let tableViewCell = cell as? CustomTableViewCell else {
            return UITableViewCell()
        }
        let weatherEntity = weatherEntities[indexPath.row]
        let entityTemp = Int(weatherEntity.temp)
        tableViewCell.configureCell(
            with: weatherEntity.title,
            subtitle: entityTemp > 0 ? "+ \(entityTemp)" : "\(entityTemp)"
        )
        let url = "\(NetworkConstants.imageUrl)\(weatherEntities[indexPath.row].icon)@2x.png"
        CustomTableViewCell.downloadImageFor(imageView: tableViewCell.weatherImageView, from: url)
        tableViewCell.selectionStyle = .none
        return tableViewCell
    }
}

// MARK: - UITableViewDelegate
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

// MARK: - WeatherListViewProtocol
extension WeatherListViewController: WeatherListViewProtocol {
    func showWeather(_ weatherEntities: [WeatherEntity]) {
        activityLoader?.dismiss()
        self.weatherEntities = weatherEntities
    }

    func showMessage(_ message: String) {
        activityLoader?.dismiss()
        alertPresenter?.show(
            with: AlertModel(
                title: NSLocalizedString("WeatherListViewController.alertController.title", comment: ""),
                message: message,
                firstButton: NSLocalizedString("WeatherListViewController.alertController.errorClose", comment: ""),
                secondButton: nil,
                firstCompletion: { },
                secondCompletion: { }
            ), style: .default
        )
    }
}

// MARK: - UISearchBarDelegate
extension WeatherListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            activityLoader?.show()
            self.presenter?.retrieveGeoLocationUsing(search: searchText)
            self.searchController.isActive = false
        }
    }
}

