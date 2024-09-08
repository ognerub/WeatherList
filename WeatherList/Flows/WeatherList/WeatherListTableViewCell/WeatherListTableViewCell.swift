import UIKit

final class WeatherListTableViewCell: UITableViewCell {
    static let reuseIdentifier = "WeatherListTableViewCell"
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
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var weatherImageView: UIImageView = {
        let image = UIImage(systemName: "")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        weatherImageView.kf.cancelDownloadTask()
    }

    func configureCell(with title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    private func configureUI() {
        self.backgroundColor = .clear
        self.addSubview(roundedView)
        self.addSubview(titleLabel)
        self.addSubview(weatherImageView)
        self.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            roundedView.topAnchor.constraint(equalTo: self.topAnchor, constant: DesignSystemConstants.standartPadding * 2),
            roundedView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            roundedView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: DesignSystemConstants.standartPadding),
            roundedView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -DesignSystemConstants.standartPadding),
            titleLabel.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: DesignSystemConstants.standartPadding),
            weatherImageView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor),
            weatherImageView.centerYAnchor.constraint(equalTo: roundedView.topAnchor),
            weatherImageView.widthAnchor.constraint(equalToConstant: DesignSystemConstants.weatherCellSize),
            weatherImageView.heightAnchor.constraint(equalToConstant: DesignSystemConstants.weatherCellSize),
            subtitleLabel.centerXAnchor.constraint(equalTo: weatherImageView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -DesignSystemConstants.standartPadding * 2)
        ])
    }
}
