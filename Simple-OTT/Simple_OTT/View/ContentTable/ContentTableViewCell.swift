//
//  ContentTableViewCell.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - ContentTableViewCellDelegate declaration

protocol ContentTableViewCellDelegate {
    func onPresent(alertController: UIAlertController)
}

// MARK: - ContentTableViewCellState declaration

private enum ContentTableViewCellState {
    case initial
    case caching
    case paused
    case resumed
    case cached
    case error
}

// MARK: - ContentTableViewCell declaration

class ContentTableViewCell: UITableViewCell {

    // MARK: - Private properties

    private var container: UIView!
    private var stackView: UIStackView!
    private var titleOptionsStackView: UIStackView!
    private var posterImageView: UIImageView!
    private var cacheActionView: CacheActionView!
    private var title: UILabel!
    private var desc: UILabel!
    private var url: UILabel!

    // MARK: - Public properties

    var delegate: ContentTableViewCellDelegate? = nil
    var viewModel: ContentTableViewCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                title.attributedText = NSAttributedString(string: viewModel.title, attributes: [ .font: UIFont.theoBoldTitle ])
                desc.text = viewModel.desc
                posterImageView.image = viewModel.posterImage
                cacheActionView.isHidden = !viewModel.showOption

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

        contentView.addSubview(container)
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
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

    private func setupLeftDetail() {
        posterImageView = UIImageView()
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(posterImageView)
        posterImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor).isActive = true
    }

    private func setupRightDetail() {
        titleOptionsStackView = THEOComponent.stackView(axis: .horizontal, spacing: 5)
        titleOptionsStackView.distribution = .fillProportionally
        titleOptionsStackView.alignment = .center

        // Title and description in a vertical stackView on the left of titleOptionsStackView
        let detailStackView = THEOComponent.stackView(axis: .vertical, spacing: 10)
        detailStackView.distribution = .fill
        detailStackView.alignment = .leading

        title = THEOComponent.label(text: "")
        title.font = .theoTitle
        title.numberOfLines = 0
        detailStackView.addArrangedSubview(title)

        desc = THEOComponent.label(text: "")
        desc.font = .theoText
        desc.numberOfLines = 0
        desc.textColor = UIColor.theoCello.withAlphaComponent(0.75)
        detailStackView.addArrangedSubview(desc)

        titleOptionsStackView.addArrangedSubview(detailStackView)

        // Cache action view on the right of titleOptionsStackView
        cacheActionView = CacheActionView()
        cacheActionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCacheActionView)))

        titleOptionsStackView.addArrangedSubview(cacheActionView)
        // Constraint the size of cacheActionView
        cacheActionView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        cacheActionView.widthAnchor.constraint(equalTo: cacheActionView.heightAnchor).isActive = true

        stackView.addArrangedSubview(titleOptionsStackView)
    }

    // MARK: - View modifiers

    private func updateView(state: ContentTableViewCellState) {
        switch state {
        case .initial:
            cacheActionView.state = .initial
        case .caching, .resumed:
            cacheActionView.state = .caching
            cacheActionView.percentage = CGFloat(viewModel?.taskPercentage ?? 0)
        case .paused:
            cacheActionView.state = .paused
        case .cached:
            cacheActionView.state = .cached
        case .error:
            // Reset UI on error
            cacheActionView.state = .initial
        }
    }

    // MARK: - CacheActionView tap handler

    private func downloadForbiddenAlert() {
        if let delegate = delegate {
            let alertController = UIAlertController(
                title: "",
                message: "You are not currently connected to WiFi and the application is not allowed to use mobile data. To change that go to Settings.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            ))
            delegate.onPresent(alertController: alertController)
        }
    }

    @objc func onCacheActionView() {
        switch cacheActionView.state {
        case .initial:
            if viewModel?.isDownloadAllowed ?? false {
                updateView(state: .caching)
                viewModel?.createCachingTask()
            } else {
                downloadForbiddenAlert()
            }
        case .caching:
            updateView(state: .paused)
            viewModel?.pauseCaching()
        case .paused:
            if viewModel?.isDownloadAllowed ?? false {
                updateView(state: .resumed)
                viewModel?.resumeCaching()
            } else {
                downloadForbiddenAlert()
            }
        case .cached:
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
}

// MARK: - ContentTableViewCellViewModelDelegate

extension ContentTableViewCell: ContentTableViewCellViewModelDelegate {
    func onProgressUpdate(percentage: Double) {
        cacheActionView.percentage = CGFloat(percentage)
    }

    func onCachePaused() {
        updateView(state: .paused)
    }

    func onCacheResumed() {
        updateView(state: .resumed)
        viewModel?.resumeCaching()
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
