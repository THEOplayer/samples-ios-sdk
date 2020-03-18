//
//  MetadataViewController.swift
//  Metadata_Handling
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - MetadataViewController declaration

class MetadataViewController: UIViewController {

    // MARK: - View properties

    private var tableView: UITableView!
    private var navigationBarTitle = ""
    private let tableCellHeight: CGFloat = 30.0

    // Static Stream array declaration used in this app
    private let streams: [Stream] = [
        Stream(name: "HLS with ID3 metadata",
               title: "HLS with ID3",
               url: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8",
               mimeType: "application/x-mpegURL",
               type: .id3),
        Stream(name: "HLS with EXT-X-PROGRAM-DATE-TIME",
               title: "HLS with PROGRAM-DATE-TIME",
               url: "https://cdn.theoplayer.com/video/star_wars_episode_vii-the_force_awakens_official_comic-con_2015_reel_(2015)/index-daterange.m3u8",
               mimeType: "application/x-mpegURL",
               type: .programDateTime),
        Stream(name: "HLS with EXT-X-DATERANGE",
               title: "HLS with DATERANGE",
               url: "https://cdn.theoplayer.com/video/star_wars_episode_vii-the_force_awakens_official_comic-con_2015_reel_(2015)/index-daterange.m3u8",
               mimeType: "application/x-mpegURL",
               type: .dateRange)
    ]

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

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
        tableView.register(MetadataTableViewCell.self, forCellReuseIdentifier: "metadataCell")

        view.addSubview(tableView)

        let layoutMarginsGuide = view.layoutMarginsGuide
        tableView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MetadataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return streams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // DequeueReusableCell for MetadataTableView as MetadataTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "metadataCell", for: indexPath)
        if let metadataCell = cell as? MetadataTableViewCell {
            // Assign stream to the MetadataTableViewCell instant
            metadataCell.stream = streams[indexPath.row]
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Instantiate playerViewController and assign stream
        if let metadataCell = tableView.cellForRow(at: indexPath) as? MetadataTableViewCell {
            let playerViewController = PlayerViewController(stream: metadataCell.stream!)
            playerViewController.navigationItem.title = navigationItem.title
            navigationItem.title = ""
            navigationController?.pushViewController(playerViewController, animated: true)
        }
    }
}
