import UIKit
import Kingfisher

protocol WeatherDetailViewProtocol: AnyObject {
    var presenter: WeatherDetailPresenterProtocol? { get set }
    // PRESENTER -> VIEW
    func showWeather(_ weather: WeatherEntity)
    func showForecast(_ forecast: ForecastEntity)
}

class WeatherDetailViewController: UIViewController {
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
        label.text = "forecast"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
    private var weatherEntity: WeatherEntity? {
        didSet {
            guard let weatherEntity = weatherEntity else { return }
            let lat = String(weatherEntity.lat)
            let lon = String(weatherEntity.lon)
            presenter?.retrieveForecastUsing(lat: lat, lon: lon)
        }
    }
    private var dayForecasts: [DayForecast] = [DayForecast(temp: 0.0, date: "Loading forecast...")] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupTableView()
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
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: DesignSystemConstants.standartPadding),
            tableView.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: DesignSystemConstants.standartPadding),
            tableView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -DesignSystemConstants.standartPadding),
            tableView.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor, constant: -DesignSystemConstants.standartPadding)
        ])
        tableView.register(WeatherListTableViewCell.self, forCellReuseIdentifier: WeatherListTableViewCell.reuseIdentifier)
    }

    @objc
    func deleteButtonPressed() {
        presenter?.deleteWeather()
    }
}

extension WeatherDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        DesignSystemConstants.weatherCellSize
    }
}

extension WeatherDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dayForecasts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let entityTemp = Int(dayForecasts[indexPath.row].temp)
        let entityTempString = entityTemp > 0 ? "+ \(entityTemp)" : "\(entityTemp)"
        cell.textLabel?.text = "\(dayForecasts[indexPath.row].date) : \(entityTempString)"
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .clear
        return cell
    }
}

extension WeatherDetailViewController: WeatherDetailViewProtocol {

    func showWeather(_ entity: WeatherEntity) {
        self.weatherEntity = entity
        titleLabel.text = entity.title
        let entityTemp = Int(entity.temp)
        subtitleLabel.text = entityTemp > 0 ? "+ \(entityTemp)" : "\(entityTemp)"
        downloadImageFor(entity: entity)
    }

    func showForecast(_ forecast: ForecastEntity) {
        let dayForecasts = forecast.forecast.compactMap { $0 }
        self.dayForecasts = dayForecasts
    }

    private func downloadImageFor(entity: WeatherEntity) {
        let url = "\(NetworkConstants.imageUrl)\(entity.icon)@2x.png"
        let processor = DownsamplingImageProcessor(size: CGSize(width: DesignSystemConstants.weatherCellSize, height: DesignSystemConstants.weatherCellSize))
        weatherImageView.kf.indicatorType = .activity
        weatherImageView.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(),
            options: [
                .processor(processor)
            ]
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                self.weatherImageView.contentMode = .scaleAspectFill
            case .failure(_):
                self.weatherImageView.image = UIImage(named: DesignSystemConstants.noIconImage)
            }
        }
    }
}
