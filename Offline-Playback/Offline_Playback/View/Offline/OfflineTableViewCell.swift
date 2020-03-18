//
//  OfflineTableViewCell.swift
//  Offline_Playback
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - OfflineTableViewCellDelegate declaration

protocol OfflineTableViewCellDelegate {
    func onPresent(alertController: UIAlertController)
}

// MARK: - OfflineTableViewCellState declaration

private enum OfflineTableViewCellState {
    case initial
    case caching
    case paused
    case resumed
    case cached
    case error
}

// MARK: - OfflineTableViewCell declaration

class OfflineTableViewCell: UITableViewCell {

    // MARK: - Private properties

    private var container: UIView!
    private var stackView: UIStackView!
    private var verticalStackView: UIStackView!
    private var titleOptionsStackView: UIStackView!
    private var posterImageView: UIImageView!
    private var optionStackView: UIStackView!
    private var progressSectionView: UIView!
    private var downloadButton: UIButton!
    private var pauseButton: UIButton!
    private var resumeButton: UIButton!
    private var removeButton: UIButton!
    private var progressView: UIProgressView!
    private var progressLabel: UILabel!
    private var title: UILabel!
    private var url: UILabel!

    // MARK: - Public properties

    var delegate: OfflineTableViewCellDelegate? = nil
    var viewModel: OfflineTableViewCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                title.text = viewModel.title
                posterImageView.image = viewModel.posterImage

                if let task = viewModel.cachingTask {
                    // Update view based on the caching task status
                    switch task.status {
                    case .idle:
                        updateView(state: .paused)
                    case .loading:
                        updateView(state: .resumed)
                    case .done:
                        updateView(state: .cached)
                    case .error:
                        updateView(state: .error)
                    default:
                        updateView(state: .initial)
                    }
                } else {
                    updateView(state: .initial)
                }
            }
        }
    }

    // MARK: - View life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setupView()
        setupContainerView()
        setupStackView()
        setupSeparator()
        setupLeftDetail()
        setupRightDetail()
    }

    // MARK: - View setup

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
    }

    private func setupContainerView() {
        container = THEOComponent.view()
        container.backgroundColor = .theoWhite
        container.layer.cornerRadius = 10
        // Set broder width for error highlight (disabled initially)
        container.layer.borderWidth = 5
        toggleErrorHighlight(enable: false)

        contentView.addSubview(container)
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    }

    private func setupStackView() {
        stackView = THEOComponent.stackView(axis: .horizontal, spacing: 10)
        stackView.distribution = .fillProportionally
        stackView.alignment = .center

        container.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10).isActive = true
        stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10).isActive = true
    }

    private func setupSeparator() {
        let separator = THEOComponent.view()

        contentView.addSubview(separator)
        separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 10).isActive = true
    }

    private func setupLeftDetail() {
        posterImageView = UIImageView()
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(posterImageView)
        posterImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 9.0 / 16.0).isActive = true
    }

    private func setupActionButton(image: UIImage?) -> UIButton {
        let button = THEOComponent.button(text: nil, image: image)
        button.layer.cornerRadius = 5
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true

        return button
    }

    private func setupActionButtons() {
        downloadButton = setupActionButton(image: UIImage(named: "download"))
        downloadButton.addTarget(self, action: #selector(onDownload), for: .touchUpInside)
        optionStackView.addArrangedSubview(downloadButton)

        pauseButton = setupActionButton(image: UIImage(named: "pause"))
        pauseButton.addTarget(self, action: #selector(onPause), for: .touchUpInside)
        pauseButton.isHidden = true
        optionStackView.addArrangedSubview(pauseButton)

        resumeButton = setupActionButton(image: UIImage(named: "download"))
        resumeButton.addTarget(self, action: #selector(onResume), for: .touchUpInside)
        resumeButton.isHidden = true
        optionStackView.addArrangedSubview(resumeButton)

        removeButton = setupActionButton(image: UIImage(named: "delete"))
        removeButton.addTarget(self, action: #selector(onRemove), for: .touchUpInside)
        removeButton.isHidden = true
        optionStackView.addArrangedSubview(removeButton)
    }

    private func setupRightDetail() {
        // verticalStackView is the container for titleOptionsStackView and progressSectionView
        verticalStackView = THEOComponent.stackView(axis: .vertical, spacing: 5)
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .center

        // titleOptionsStackView is a horizontal stackView for title and a stack of option buttons
        titleOptionsStackView = THEOComponent.stackView(axis: .horizontal, spacing: 5)
        titleOptionsStackView.distribution = .fillProportionally
        titleOptionsStackView.alignment = .center

        title = THEOComponent.label(text: "")
        title.font = .theoTitle
        title.numberOfLines = 2
        titleOptionsStackView.addArrangedSubview(title)

        // Setup option stack view for option buttons
        optionStackView = THEOComponent.stackView(axis: .horizontal, spacing: 5)
        optionStackView.distribution = .equalSpacing
        optionStackView.alignment = .trailing
        // Setup all option buttons and show/hide them accordingly based on the cell state
        setupActionButtons()
        titleOptionsStackView.addArrangedSubview(optionStackView)

        // Add titleOptionsStackView to verticalStackView and set constraint
        verticalStackView.addArrangedSubview(titleOptionsStackView)
        titleOptionsStackView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor).isActive = true

        // progressSectionView is the container for progresView and progressLabel
        progressSectionView = THEOComponent.view()
        // Hide progressSectionView by default
        progressSectionView.isHidden = true

        // Setup progressView
        progressView = THEOComponent.progressView()
        progressSectionView.addSubview(progressView)
        progressView.heightAnchor.constraint(lessThanOrEqualTo: progressSectionView.heightAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: progressSectionView.leadingAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: progressSectionView.centerYAnchor).isActive = true
        // Reserve space for progresLabel
        progressView.widthAnchor.constraint(equalTo: progressSectionView.widthAnchor, constant: -45).isActive = true

        // Setup progressLabel
        progressLabel = THEOComponent.label(text: "0%")
        progressSectionView.addSubview(progressLabel)
        progressLabel.trailingAnchor.constraint(equalTo: progressSectionView.trailingAnchor).isActive = true
        progressLabel.centerYAnchor.constraint(equalTo: progressSectionView.centerYAnchor).isActive = true

        // Add progressSectionView to verticalStackView and set constraint
        verticalStackView.addArrangedSubview(progressSectionView)
        progressSectionView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor).isActive = true

        stackView.addArrangedSubview(verticalStackView)
        // Height of verticalStackView will be handled by stackView autoLayout
        verticalStackView.heightAnchor.constraint(greaterThanOrEqualTo: posterImageView.heightAnchor).isActive = true
    }

    // MARK: - View modifiers

    private func toggleErrorHighlight(enable: Bool) {
        if enable {
            container.layer.borderColor = UIColor.theoStrongRed.cgColor
        } else {
            container.layer.borderColor = UIColor.theoWhite.cgColor
        }
    }

    private func setProgress(percentage: Double) {
        let rounded = Int((percentage * 100).rounded())
        progressView.progress = Float(percentage)
        progressLabel.text = "\(rounded)%"
    }

    private func updateView(state: OfflineTableViewCellState) {
        switch state {
        case .initial:
            progressSectionView.isHidden = true
            downloadButton.isHidden = false
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            removeButton.isHidden = true
            setProgress(percentage: 0.0)
            toggleErrorHighlight(enable: false)
        case .caching:
            progressSectionView.isHidden = false
            downloadButton.isHidden = true
            pauseButton.isHidden = false
            resumeButton.isHidden = true
            removeButton.isHidden = false
            toggleErrorHighlight(enable: false)
        case .paused:
            progressSectionView.isHidden = false
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = false
            removeButton.isHidden = false
        case .resumed:
            progressSectionView.isHidden = false
            downloadButton.isHidden = true
            pauseButton.isHidden = false
            resumeButton.isHidden = true
            removeButton.isHidden = false
            // Get latest percentage immediately
            if let percentage = viewModel?.taskPercentage {
                setProgress(percentage: percentage)
            }
            toggleErrorHighlight(enable: false)
        case .cached:
            progressSectionView.isHidden = true
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = true
            removeButton.isHidden = false
        case .error:
            progressSectionView.isHidden = false
            downloadButton.isHidden = true
            pauseButton.isHidden = true
            resumeButton.isHidden = false
            removeButton.isHidden = false
            toggleErrorHighlight(enable: true)
        }
    }

    // MARK: - UIButton actions

    @objc func onDownload(_ sender: Any) {
        updateView(state: .caching)
        viewModel?.createCachingTask()
    }

    @objc func onPause(_ sender: Any) {
        updateView(state: .paused)
        viewModel?.pauseCaching()
    }

    @objc func onResume(_ sender: Any) {
        updateView(state: .resumed)
        viewModel?.resumeCaching()
    }

    @objc func onRemove(_ sender: Any) {
        if let delegate = delegate {
            // Instantiate UIAlertController and present it with delegate
            let alertController = UIAlertController(
                title: "Confirm",
                message: "\(viewModel!.isCached ? "Removing" : "Cancelling") caching for \"\(viewModel!.title)\"?",
                preferredStyle: .alert
            )

            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default) { action -> Void in
                    // In case cache evicted while user deciding
                    if !self.viewModel!.isEvicted {
                        // Remove cache and reset UI
                        self.viewModel?.removeCaching()
                        self.updateView(state: .initial)
                    }
                }
            )

            alertController.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            ))
            delegate.onPresent(alertController: alertController)
        }
    }
}

// MARK: - OfflineTableViewCellViewModelDelegate

extension OfflineTableViewCell: OfflineTableViewCellViewModelDelegate {
    func onProgressUpdate(percentage: Double) {
        setProgress(percentage: percentage)
        progressView.layoutIfNeeded()
    }

    func onCacheResumed() {
        updateView(state: .resumed)
        onResume(self)
    }

    func onCacheCompleted() {
        updateView(state: .cached)
    }

    func onCacheRemoved() {
        updateView(state: .initial)
    }

    func onError() {
        updateView(state: .error)
    }
}
