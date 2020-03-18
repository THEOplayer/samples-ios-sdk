//
//  AdsConfViewController.swift
//  Custom_Ads
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit
import os.log

// MARK: - AdsConfViewController declaration

class AdsConfViewController: UIViewController {

    // MARK: - Private properties

    // UI Components
    private var scrollView: UIScrollView!
    private var vStackView: UIStackView!
    private var playButton: UIButton!
    private var adsTypeTable: UITableView!
    private var adsPlacementTable: UITableView!
    private var adsUrlTextView: UITextView!
    private var videoUrlTextView: UITextView!
    private var scrollViewObs: [NSKeyValueObservation] = [NSKeyValueObservation]()

    // User configurable properties
    private var adsTypeIndex: Int = 0
    private var adsPlacementIndex: Int = 0
    private var adsUrl: String = ""
    private var videoUrl: String = ""
    private var navigationBarTitle = ""

    // Constant properties
    private let adTypeTitle = "Advertisement Standard"
    private let adPlacementTitle = "Advertisement Placement"
    private let adsUrlTitle = "Advertisement Url"
    private let videoUrlTitle = "Video Url"
    private let adsTypeArray: [String] = [
        "VAST",
        "VMAP",
        "VPAID"
    ]
    private let adsPlacementArray: [String] = [
        "Pre-roll",
        "Mid-roll",
        "Post-roll"
    ]
    private let adsUrlDict: [String: String] = [
        "VAST": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=",
        "VMAP": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpost&cmsid=496&vid=short_onecue&correlator=",
        "VPAID": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinearvpaid2js&correlator="
    ]
    private let defaultVideoUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8"
    private let cornerRadius: CGFloat = 10.0
    private let tableCellHeight: CGFloat = 30.0

    // MARK: - Class life cycle

    func deInit() {
        // Free UIScrollView content size obversations
        scrollViewObs.removeAll()
    }

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        setupView()
        setupScrollView()
        setupStackView()
        setupAdsTypeStack()
        setupAdsPlacementStack()
        setupAdsUrlTextStack()
        setupVideoUrlTextStack()
        setupPlayButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        // NavifationItem title will set to empty string before pushing PlayerViewController, hence need to reset it here.
        navigationItem.title = navigationBarTitle

        registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        deregisterKeyboardNotifications()
    }

    // MARK: - View setup

    private func setupView() {
        navigationBarTitle = navigationController?.navigationBar.topItem?.title ?? ""

        view.backgroundColor = .theoCello

        // Set navigationBar title's text color
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.theoWhite]
        navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]

        // Setup tap gesture to detect tapping outside of UITextViews
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)
    }

    private func setupScrollView() {
        scrollView = THEOComponent.scrollView()

        view.addSubview(scrollView)

        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }

    private func setupStackView() {
        vStackView = THEOComponent.stackView()

        scrollView.addSubview(vStackView)

        vStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10).isActive = true
        vStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        vStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10).isActive = true
        vStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -20).isActive = true
    }

    private func setupAdsTypeStack() {
        let stackView = THEOComponent.stackView(spacing: 5.0)

        let title = THEOComponent.titleView(text: adTypeTitle)
        stackView.addArrangedSubview(title)

        adsTypeTable = THEOComponent.tableView()
        adsTypeTable.layer.cornerRadius = cornerRadius
        adsTypeTable.delegate = self
        adsTypeTable.dataSource = self
        adsTypeTable.register(AdsTableViewCell.self, forCellReuseIdentifier: "adsTypeCell")
        adsTypeTable.heightAnchor.constraint(equalToConstant: tableCellHeight * CGFloat(adsTypeArray.count)).isActive = true
        stackView.addArrangedSubview(adsTypeTable)

        vStackView.addArrangedSubview(stackView)
    }

    private func setupAdsPlacementStack() {
        let stackView = THEOComponent.stackView(spacing: 5.0)

        let title = THEOComponent.titleView(text: adPlacementTitle)
        stackView.addArrangedSubview(title)

        adsPlacementTable = THEOComponent.tableView()
        adsPlacementTable.layer.cornerRadius = cornerRadius
        adsPlacementTable.delegate = self
        adsPlacementTable.dataSource = self
        adsPlacementTable.register(AdsTableViewCell.self, forCellReuseIdentifier: "adsPlacementCell")
        adsPlacementTable.heightAnchor.constraint(equalToConstant: tableCellHeight * CGFloat(adsPlacementArray.count)).isActive = true
        stackView.addArrangedSubview(adsPlacementTable)

        vStackView.addArrangedSubview(stackView)
    }

    private func setupScrollableTextView(stackView: UIStackView, placeholderText: String) -> UITextView {
        let (scrollView, textView) = THEOComponent.scrollableTextView()

        // Flash scroll bar on content size changes
        scrollViewObs.append(scrollView.observe(\.contentSize) { object, change in
            if object.isUserInteractionEnabled {
                object.flashScrollIndicators()
            }
        })

        scrollView.heightAnchor.constraint(equalToConstant: (textView.font!.lineHeight * 4) + 5).isActive = true

        stackView.addArrangedSubview(scrollView)

        // Set TextView text
        textView.text = placeholderText

        return textView
    }

    private func setupAdsUrlTextStack() {
        let stackView = THEOComponent.stackView(spacing: 5.0)

        let title = THEOComponent.titleView(text: adsUrlTitle)
        stackView.addArrangedSubview(title)

        adsUrl = adsUrlDict[adsTypeArray[adsTypeIndex]]!
        adsUrlTextView = setupScrollableTextView(stackView: stackView, placeholderText: adsUrl)
        adsUrlTextView.delegate = self

        vStackView.addArrangedSubview(stackView)
    }

    private func setupVideoUrlTextStack() {
        let stackView = THEOComponent.stackView(spacing: 5.0)

        let title = THEOComponent.titleView(text: videoUrlTitle)
        stackView.addArrangedSubview(title)

        videoUrl = defaultVideoUrl
        videoUrlTextView = setupScrollableTextView(stackView: stackView, placeholderText: videoUrl)
        videoUrlTextView.delegate = self

        vStackView.addArrangedSubview(stackView)
    }

    private func setupPlayButton() {
        let stackView = THEOComponent.stackView(spacing: 0.0)
        stackView.alignment = .center

        playButton = THEOComponent.textButton(text: "PLAY")
        playButton.addTarget(self, action: #selector(onButtonPressed), for: .touchUpInside)

        // Wrap playButton by another stackView to avoid stretching playButton
        stackView.addArrangedSubview(playButton)

        vStackView.addArrangedSubview(stackView)
    }

    // MARK: - Keyborad notifications

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardFrameUpdate), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardFrameUpdate), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    private func deregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    // MARK: - @objc functions

    @objc func onKeyboardFrameUpdate(notification: Notification) {
        // Work out the keyboard size and give scrollView extra space to scroll over the keyboard
        guard let keyboardFrameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardFrameEndFromView = view.convert(keyboardFrameEnd.cgRectValue, from: view.window)

        if notification.name == UIResponder.keyboardDidHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrameEndFromView.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    @objc func onTapped() {
        // End UITextViews editing when user tapped outside of the UITextViews
        adsUrlTextView.endEditing(true)
        videoUrlTextView.endEditing(true)
    }

    @objc func onButtonPressed(sender: UIButton!) {
        // Reset scrollView content inset in case keyboard is still on display when button is pressed
        scrollView.contentInset = .zero

        // Instantiate PlayerViewController, configure it then push to navigationContoller
        let playerViewController = PlayerViewController()
        playerViewController.videoUrl = videoUrl
        playerViewController.adsUrl = adsUrl
        playerViewController.adsType = adsTypeArray[adsTypeIndex]
        playerViewController.adPlacement = adsPlacementArray[adsPlacementIndex]
        playerViewController.navigationItem.title = navigationItem.title
        navigationItem.title = ""
        navigationController?.pushViewController(playerViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AdsConfViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Use fixed table cell height
        return tableCellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return data size for the corresponding UITableView
        switch tableView {
        case adsTypeTable:
            return adsTypeArray.count
        case adsPlacementTable:
            return adsPlacementArray.count
        default:
            os_log("Unkown UITableView")
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // DequeueReusableCell for the corresponding UITableView, configure the AdsTableViewCell
        switch tableView {
        case adsTypeTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "adsTypeCell", for: indexPath)
            cell.detailTextLabel?.text = adsTypeArray[indexPath.row]
            cell.accessoryType = indexPath.row == adsTypeIndex ? .checkmark : .none
            return cell
        case adsPlacementTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "adsPlacementCell", for: indexPath)
            cell.detailTextLabel?.text = adsPlacementArray[indexPath.row]
            cell.accessoryType = indexPath.row == adsPlacementIndex ? .checkmark : .none
            return cell
        default:
            os_log("Unkown UITableView")
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Reset checkmark from last cell and set checkmark to new cell
        switch tableView {
        case adsTypeTable:
            if let oldCell = tableView.cellForRow(at: IndexPath(row: adsTypeIndex, section: 0)) {
                oldCell.accessoryType = .none
            }
            if let newCell = tableView.cellForRow(at: indexPath) {
                // If user has not changed the ad url then set the new default ad url
                if adsUrl == adsUrlDict[adsTypeArray[adsTypeIndex]] {
                    adsUrl = adsUrlDict[adsTypeArray[indexPath.row]]!
                    adsUrlTextView.text = adsUrl
                    // Retrieve UIScrollView to scroll to top
                    let scrollView = adsUrlTextView.superview as? UIScrollView
                    scrollView?.contentOffset.y = 0
                }
                adsTypeIndex = indexPath.row
                newCell.accessoryType = .checkmark
            }
            // Disable ads placement table if ads type is "VMAP"
            if adsTypeArray[adsTypeIndex] == "VMAP" {
                adsPlacementTable.isUserInteractionEnabled = false
                adsPlacementTable.alpha = 0.5
            } else {
                adsPlacementTable.isUserInteractionEnabled = true
                adsPlacementTable.alpha = 1.0
            }
        case adsPlacementTable:
            if let oldCell = tableView.cellForRow(at: IndexPath(row: adsPlacementIndex, section: 0)) {
                oldCell.accessoryType = .none
            }
            if let newCell = tableView.cellForRow(at: indexPath) {
                adsPlacementIndex = indexPath.row
                newCell.accessoryType = .checkmark
            }
        default:
            os_log("Unkown UITableView")
        }
    }
}

// MARK: - UITextViewDelegate

extension AdsConfViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Empty UITextView if current string matches the default
        switch textView {
        case adsUrlTextView:
            if let userAdsUrl = textView.text, userAdsUrl == adsUrlDict[adsTypeArray[adsTypeIndex]]! {
                textView.text = ""
            }
        case videoUrlTextView:
            if let userVideoUrl = textView.text, userVideoUrl == defaultVideoUrl {
                textView.text = ""
            }
        default:
            os_log("Unkown UITextView")
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Reset text view with default string if there is no user input.
        switch textView {
        case adsUrlTextView:
            if let userAdsUrl = textView.text, userAdsUrl != "" {
                adsUrl = userAdsUrl
            } else {
                adsUrl = adsUrlDict[adsTypeArray[adsTypeIndex]]!
            }
            textView.text = adsUrl
        case videoUrlTextView:
            if let userVideoUrl = textView.text, userVideoUrl != "" {
                videoUrl = userVideoUrl
            } else {
                videoUrl = defaultVideoUrl
            }
            textView.text = videoUrl
        default:
            os_log("Unkown UITextView")
        }
    }
}
