import UIKit

protocol WeatherDetailViewProtocol: AnyObject {
    var presenter: WeatherDetailPresenterProtocol? { get set }
    // PRESENTER -> VIEW
    func showWeather(_ weather: WeatherEntity)
}

class WeatherDetailViewController: UIViewController {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var presenter: WeatherDetailPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }

    @objc
    func deleteTapped() {
        presenter?.deleteWeather()
    }
}

extension WeatherDetailViewController: WeatherDetailViewProtocol {
    func showWeather(_ weather: WeatherEntity) {
        titleLabel.text = weather.title
        contentLabel.text = String(weather.temp)
    }
}
