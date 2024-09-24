import UIKit

protocol WeatherDetailViewProtocol: AnyObject {
    var presenter: WeatherDetailPresenterProtocol? { get set }
    // PRESENTER -> VIEW
    func showWeather(_ weather: WeatherEntity)
    func showForecasts(_ forecasts: [[DayForecast]])
    func showMessage(_ message: String)
}

final class WeatherDetailViewController: UIViewController {
    // MARK: Properties
    lazy var roundedView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = DesignSystemConstants.standartPadding
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: DesignSystemConstants.customOrangeColor)
        label.font = UIFont.systemFont(ofSize: DesignSystemConstants.textTitleSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        return tableView
    }()
    lazy var weatherImageView: UIImageView = {
        let image = UIImage(systemName: "")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonPressed))
        button.tintColor = UIColor(named: DesignSystemConstants.customOrangeColor)
        return button
    }()
    var presenter: WeatherDetailPresenterProtocol?
    private let dateFormatter = DateFormatterService()
    private var activityLoader: UIBlockingProgressHUD?
    private var alertPresenter: AlertPresenterProtocol?
    private var weatherEntity: WeatherEntity? {
        didSet {
            guard let weatherEntity = weatherEntity else { return }
            let lat = String(weatherEntity.lat)
            let lon = String(weatherEntity.lon)
            presenter?.retrieveForecastUsing(lat: lat, lon: lon)
        }
    }
    private var dayForecasts: [[DayForecast]] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        activityLoader = UIBlockingProgressHUD(viewController: self)
        alertPresenter = AlertPresenterImpl(viewController: self)
        setupUI()
        activityLoader?.show()
        presenter?.viewDidLoad()
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = deleteButton
        view.addSubview(roundedView)
        view.addSubview(weatherImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            weatherImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weatherImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roundedView.topAnchor.constraint(equalTo: weatherImageView.centerYAnchor),
            roundedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DesignSystemConstants.standartPadding),
            roundedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignSystemConstants.standartPadding),
            roundedView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DesignSystemConstants.standartPadding),
            titleLabel.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: weatherImageView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystemConstants.standartPadding),
            subtitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor)
        ])
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: DesignSystemConstants.standartPadding),
            tableView.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor, constant: -DesignSystemConstants.standartPadding)
        ])
        tableView.register(CustomTableViewHeader.self, forHeaderFooterViewReuseIdentifier: CustomTableViewHeader.reuseIdentifier)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
    }

    @objc
    func deleteButtonPressed() {
        alertPresenter?.show(
            with: AlertModel(
                title: NSLocalizedString("WeatherListViewController.alertController.title", comment: ""),
                message: NSLocalizedString("WeatherDetailViewController.alertController.askForDelete", comment: ""),
                firstButton: NSLocalizedString("WeatherDetailViewController.alertController.deleteItem", comment: ""),
                secondButton: NSLocalizedString("WeatherListViewController.alertController.addItemCancel", comment: ""),
                firstCompletion: { self.presenter?.deleteWeather() },
                secondCompletion: { }
            ), style: .destructive
        )
    }
}

//MARK: - UITableViewDelegate
extension WeatherDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        DesignSystemConstants.weatherCellSize
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        DesignSystemConstants.weatherCellSize / 2
    }
}

// MARK: - UITableViewDataSource
extension WeatherDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dayForecasts.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomTableViewHeader.reuseIdentifier)
        guard let tableViewHeader = header as? CustomTableViewHeader else {
            return UITableViewHeaderFooterView()
        }
        tableViewHeader.configureHeader(with: createHeaderDate(for: section) ?? "")
        return tableViewHeader
    }

    private func createHeaderDate(for section: Int) -> String? {
        guard let date = dayForecasts[section].first?.date else { return nil }
        let stringDate = dateFormatter.getString(from: date)
        let time = stringDate.suffix(5)
        let onlyDate = String(stringDate.replacingOccurrences(of: time, with: ""))
        return onlyDate
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayForecasts[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath)
        guard let tableViewCell = cell as? CustomTableViewCell else {
            return UITableViewCell()
        }
        configure(cell: tableViewCell, for: indexPath)
        return tableViewCell
    }

    private func configure(cell: CustomTableViewCell, for indexPath: IndexPath) {
        let weatherForecast = dayForecasts[indexPath.section][indexPath.row]
        let entityDate = String(dateFormatter.getString(from: weatherForecast.date).suffix(5))
        let entityTemp = weatherForecast.temp
        cell.configureCell(
            with: entityDate,
            subtitle: entityTemp
        )
        let url = "\(NetworkConstants.imageUrl)\(weatherForecast.icon)@2x.png"
        CustomTableViewCell.downloadImageFor(imageView: cell.weatherImageView, from: url)
    }
}

// MARK: - WeatherDetailViewProtocol
extension WeatherDetailViewController: WeatherDetailViewProtocol {

    func showWeather(_ entity: WeatherEntity) {
        weatherEntity = entity
        titleLabel.text = entity.title
        subtitleLabel.text = entity.temp
        let url = "\(NetworkConstants.imageUrl)\(entity.icon)@2x.png"
        CustomTableViewCell.downloadImageFor(imageView: weatherImageView, from: url)
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

    func showForecasts(_ forecasts: [[DayForecast]]) {
        activityLoader?.dismiss()
        self.dayForecasts = forecasts
    }
}
