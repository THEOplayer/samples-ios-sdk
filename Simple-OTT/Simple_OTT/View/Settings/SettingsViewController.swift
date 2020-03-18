//
//  SettingsViewController.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - SettingsViewController declaration

class SettingsViewController: UIViewController {

    // MARK: - Private properties

    private let viewModel: SettingsViewViewModel
    private var wifiOnlyDownloadView: UIView!
    private var toggleSwitch: UISwitch!
    private var bottomOptionStackView: UIStackView!
    private var clearButton: UIButton!

    // MARK: - View life cycle

    init(viewModel: SettingsViewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupWifiOnlyDownloadSwitch()
        setupOptionStackView()
    }

    // MARK: - View setup

    private func setupView() {
        view.backgroundColor = .clear
    }

    private func setupWifiOnlyDownloadSwitch() {
        wifiOnlyDownloadView = THEOComponent.view()
        wifiOnlyDownloadView.backgroundColor = .theoWhite
        wifiOnlyDownloadView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let wifiOnlyDownloadStackView = THEOComponent.stackView(axis: .horizontal, spacing: 0)
        wifiOnlyDownloadView.addSubview(wifiOnlyDownloadStackView)
        let layoutMarginsGuide = wifiOnlyDownloadView.layoutMarginsGuide
        wifiOnlyDownloadStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        wifiOnlyDownloadStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        wifiOnlyDownloadStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        wifiOnlyDownloadStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true

        let label = THEOComponent.label(text: "Only download on Wifi")
        wifiOnlyDownloadStackView.addArrangedSubview(label)

        toggleSwitch = THEOComponent.switchButton(isOn: viewModel.wifiOnlyDownload)
        toggleSwitch.addTarget(self, action: #selector(onToggleSwitchValueChanged), for: .valueChanged)
        wifiOnlyDownloadStackView.addArrangedSubview(toggleSwitch)

        view.addSubview(wifiOnlyDownloadView)
        wifiOnlyDownloadView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        wifiOnlyDownloadView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        wifiOnlyDownloadView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func setupOptionStackView() {
        bottomOptionStackView = THEOComponent.stackView(spacing: 10)
        bottomOptionStackView.alignment = .center

        clearButton = THEOComponent.textButton(text: "CLEAR ALL DOWNLOADS")
        clearButton.addTarget(self, action: #selector(onClearButton), for: .touchUpInside)
        bottomOptionStackView.addArrangedSubview(clearButton)

        view.addSubview(bottomOptionStackView)
        bottomOptionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomOptionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomOptionStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }

    // MARK: - UISwitch handler

    @objc private func onToggleSwitchValueChanged() {
        viewModel.wifiOnlyDownload = toggleSwitch.isOn
    }

    // MARK: - Clear all download handler

    @objc private func onClearButton() {
        let alertController = UIAlertController(
            title: "Confirm",
            message: "All downloaded movies will be permanently deleted. Are you sure?",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default) { action -> Void in
                self.viewModel.clearAllDownloads()
            }
        )

        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))

        present(alertController, animated: true, completion: nil)
    }
}
