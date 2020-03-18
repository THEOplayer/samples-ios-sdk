//
//  OfflineViewController.swift
//  Offline_Playback
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - OfflineViewController declaration

class OfflineViewController: UIViewController {

    // MARK: - View properties

    private var tableView: UITableView!
    private var navigationBarTitle = ""

    // ViewModel object that contains the streams
    let viewModel: OfflineViewViewModel = OfflineViewViewModel()

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        setupView()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        // NavifationItem title will set to empty string before pushing PlayerViewController, hence need to reset it here.
        navigationItem.title = navigationBarTitle
    }

    // MARK: - View setup

    private func setupView() {
        navigationBarTitle = navigationController?.navigationBar.topItem?.title ?? ""

        view.backgroundColor = .theoCello
        // Create padding around the view
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    }

    private func setupTableView() {
        tableView = THEOComponent.tableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OfflineTableViewCell.self, forCellReuseIdentifier: "offlineStreamCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        view.addSubview(tableView)

        let layoutMarginsGuide = view.layoutMarginsGuide
        tableView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension OfflineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Reset viewModel delegate to avoid unexpected UI changes to the offlineStreamCell
        if let offlineStreamCell = cell as? OfflineTableViewCell {
            offlineStreamCell.viewModel?.delegate = nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // DequeueReusableCell for OfflineTableView as OfflineTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "offlineStreamCell", for: indexPath)
        if let offlineStreamCell = cell as? OfflineTableViewCell {
            offlineStreamCell.delegate = self
            // Assign viewModel to the cell object and set the cell as the viewModel's delegate
            offlineStreamCell.viewModel = viewModel.cellViewModels[indexPath.row]
            offlineStreamCell.viewModel?.delegate = offlineStreamCell
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Instantiate playerViewController and assign source description
        if let offlineStreamCell = tableView.cellForRow(at: indexPath) as? OfflineTableViewCell {
            let playerViewController = PlayerViewController()
            playerViewController.source = offlineStreamCell.viewModel?.source ?? nil
            playerViewController.navigationItem.title = navigationItem.title
            navigationItem.title = ""
            navigationController?.pushViewController(playerViewController, animated: true)
        }
    }
}

// MARK: - OfflineTableViewCellDelegate

extension OfflineViewController: OfflineTableViewCellDelegate {
    func onPresent(alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
    }
}
