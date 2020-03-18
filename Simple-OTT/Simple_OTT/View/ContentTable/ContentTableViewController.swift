//
//  ContentTableViewController.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - ContentTableViewController declaration

class ContentTableViewController: UITableViewController {

    // MARK: - Private properties

    private let viewModel: ContentTableViewViewModel

    // MARK: - View life cycle

    init(viewModel: ContentTableViewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - View setup

    private func setupView() {
        view.backgroundColor = .clear
    }

    private func setupTableView() {
        tableView.bounces = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .black
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "contentTableViewCell")
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contentTableViewCellVMs.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contentTableViewCell", for: indexPath)
        if let contentTableViewCell = cell as? ContentTableViewCell {
            contentTableViewCell.delegate = self
            contentTableViewCell.viewModel = viewModel.contentTableViewCellVMs[indexPath.row]
            // Set cell as viewModel's delegate
            contentTableViewCell.viewModel?.delegate = contentTableViewCell
            contentTableViewCell.setNeedsDisplay()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Instantiate playerViewController and assign source description
        if let contentTableViewCell = tableView.cellForRow(at: indexPath) as? ContentTableViewCell {
            let playerViewController = PlayerViewController()
            playerViewController.source = contentTableViewCell.viewModel?.source ?? nil
            playerViewController.navigationItem.title = ""
            navigationItem.title = ""
            navigationController?.pushViewController(playerViewController, animated: true)
        }
    }
}

// MARK: - ContentTableViewCellDelegate

extension ContentTableViewController: ContentTableViewCellDelegate {
    func onPresent(alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
    }
}
