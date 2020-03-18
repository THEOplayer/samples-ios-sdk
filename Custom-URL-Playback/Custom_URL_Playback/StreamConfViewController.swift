//
//  StreamConfViewController.swift
//  Custom_URL_Playback
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit
import os.log

// MARK: - StreamConfViewController declaration

class StreamConfViewController: UIViewController {

    // MARK: - Private properties

    // UI Components
    private var scrollView: UIScrollView!
    private var vStackView: UIStackView!
    private var playButton: UIButton!
    private var streamTypeTable: UITableView!
    private var videoUrlTextView: UITextView!
    private var licenseUrlTextView: UITextView!
    private var certificateUrlTextView: UITextView!
    private var scrollViewObs: [NSKeyValueObservation] = [NSKeyValueObservation]()

    // User configurable properties
    private var streamIndex: Int = 0
    private var videoUrl: String = ""
    private var licenseUrl: String = ""
    private var certificateUrl: String = ""
    private var navigationBarTitle = ""

    // Constant properties
    private let streamTypeTitle = "Stream Type"
    private let videoUrlTitle = "Video Url"
    private let licenseUrlTitle = "FairPlay License Url"
    private let certificateUrlTitle = "FairPlay Certificate Url"
    private let cornerRadius: CGFloat = 10.0
    private let tableCellHeight: CGFloat = 30.0
    private let streams: [Stream] = [
        Stream(title: "Clear",
               url: "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8",
               mimeType: "application/x-mpegURL",
               isClear: true,
               licenseUrl: "",
               certificateUrl: ""),
        Stream(title: "DRM Protected",
               url: "https://fps.ezdrm.com/demo/video/ezdrm.m3u8",
               mimeType: "application/x-mpegURL",
               isClear: false,
               licenseUrl: "https://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe",
               certificateUrl: "https://fps.ezdrm.com/demo/video/eleisure.cer")
    ]

    // MARK: - Class life cycle

    func deInit() {
        // Free UIScrollView content size obversations
        scrollViewObs.removeAll()
    }

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        setupUI()
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

    private func setupUI() {
        setupView()
        setupScrollView()
        setupStackView()
        setupStreamTypeStack()
        setupVideoUrlTextStack()
        setupLicenseUrlTextStack()
        setupCertificateUrlTextStack()
        setupPlayButton()
    }

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

    private func setupStreamTypeStack() {
        let stackView = THEOComponent.stackView(spacing: 5.0)

        let title = THEOComponent.titleView(text: streamTypeTitle)
        stackView.addArrangedSubview(title)

        streamTypeTable = THEOComponent.tableView()
        streamTypeTable.layer.cornerRadius = cornerRadius
        streamTypeTable.delegate = self
        streamTypeTable.dataSource = self
        streamTypeTable.register(StreamTableViewCell.self, forCellReuseIdentifier: "streamTypeCell")
        streamTypeTable.heightAnchor.constraint(equalToConstant: tableCellHeight * 2).isActive = true
        stackView.addArrangedSubview(streamTypeTable)

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

    private func setupVideoUrlTextStack() {
        let stackView = THEOComponent.stackView(spacing: 5.0)

        let title = THEOComponent.titleView(text: videoUrlTitle)
        stackView.addArrangedSubview(title)

        videoUrl = streams[streamIndex].url
        videoUrlTextView = setupScrollableTextView(stackView: stackView, placeholderText: videoUrl)
        videoUrlTextView.delegate = self

        vStackView.addArrangedSubview(stackView)
    }

    private func setupLicenseUrlTextStack() {
        let stackView = THEOComponent.stackView(spacing: 5.0)

        let title = THEOComponent.titleView(text: licenseUrlTitle)
        stackView.addArrangedSubview(title)

        licenseUrl = streams[streamIndex].licenseUrl
        licenseUrlTextView = setupScrollableTextView(stackView: stackView, placeholderText: licenseUrl)
        licenseUrlTextView.delegate = self

        // Clear stream is default, hence disabling it
        toggleTextView(textView: licenseUrlTextView, enable: false)

        vStackView.addArrangedSubview(stackView)
    }

    private func setupCertificateUrlTextStack() {
        let stackView = THEOComponent.stackView(spacing: 5.0)

        let title = THEOComponent.titleView(text: certificateUrlTitle)
        stackView.addArrangedSubview(title)

        certificateUrl = streams[streamIndex].certificateUrl
        certificateUrlTextView = setupScrollableTextView(stackView: stackView, placeholderText: certificateUrl)
        certificateUrlTextView.delegate = self

        // Clear stream is default, hence disabling it
        toggleTextView(textView: certificateUrlTextView, enable: false)

        vStackView.addArrangedSubview(stackView)
    }

    private func setupPlayButton() {
        let stackView = THEOComponent.stackView(spacing: 0.0)
        stackView.alignment = .center

        playButton = THEOComponent.textButton(text: "Play")
        playButton.addTarget(self, action: #selector(onButtonPressed), for: .touchUpInside)

        // Wrap playButton by another stackView to avoid stretching playButton
        stackView.addArrangedSubview(playButton)

        vStackView.addArrangedSubview(stackView)
    }

    // MARK: - View Update

    private func toggleTextView(textView: UITextView, enable: Bool) {
        if let scrollView = textView.superview as? UIScrollView {
            if enable {
                scrollView.isUserInteractionEnabled = true
                scrollView.alpha = 1.0
                scrollView.flashScrollIndicators()
            } else {
                scrollView.isUserInteractionEnabled = false
                scrollView.alpha = 0.5
            }
        } else {
            os_log("UITextView is not wrapped in UIScrollView. Skipping.")
        }
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
        videoUrlTextView.endEditing(true)
        licenseUrlTextView.endEditing(true)
    }

    @objc func onButtonPressed(sender: UIButton!) {
        // Reset scrollView content inset in case keyboard is still on display when button is pressed
        scrollView.contentInset = .zero

        // Instantiate PlayerViewController, configure it then push to navigationContoller
        let playerViewController = PlayerViewController()
        playerViewController.videoUrl = videoUrl
        playerViewController.mimeType = streams[streamIndex].mimeType
        playerViewController.isClearStream = streams[streamIndex].isClear
        if !streams[streamIndex].isClear {
            playerViewController.isClearStream = false
            playerViewController.licenseUrl = licenseUrl
            playerViewController.certificateUrl = certificateUrl
        }
        playerViewController.navigationItem.title = navigationItem.title
        navigationItem.title = ""
        navigationController?.pushViewController(playerViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension StreamConfViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Use fixed table cell height
        return tableCellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return data size for the corresponding UITableView
        switch tableView {
        case streamTypeTable:
            return streams.count
        default:
            os_log("Unkown UITableView")
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // DequeueReusableCell for the corresponding UITableView, configure the AdsTableViewCell
        switch tableView {
        case streamTypeTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "streamTypeCell", for: indexPath)
            cell.detailTextLabel?.text = streams[indexPath.row].title
            cell.accessoryType = indexPath.row == streamIndex ? .checkmark : .none
            return cell
        default:
            os_log("Unkown UITableView")
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Reset checkmark from last cell and set checkmark to new cell
        switch tableView {
        case streamTypeTable:
            if let oldCell = tableView.cellForRow(at: IndexPath(row: streamIndex, section: 0)) {
                // Reset cell check mark
                oldCell.accessoryType = .none
            }
            if let newCell = tableView.cellForRow(at: indexPath) {
                let oldStream = streams[streamIndex]
                let newStream = streams[indexPath.row]

                // If user has not changed the stream url then set the new default stream url
                if videoUrl == oldStream.url {
                    videoUrl = newStream.url
                    videoUrlTextView.text = videoUrl
                    // Retrieve UIScrollView to scroll to top
                    let scrollView = videoUrlTextView.superview as? UIScrollView
                    scrollView?.contentOffset.y = 0
                }

                // If user has not changed the license url then set the new default license url
                if licenseUrl == oldStream.licenseUrl {
                    licenseUrl = newStream.licenseUrl
                    licenseUrlTextView.text = licenseUrl
                    // Retrieve UIScrollView to scroll to top
                    let scrollView = licenseUrlTextView.superview as? UIScrollView
                    scrollView?.contentOffset.y = 0
                }

                // If user has not changed the certificate url then set the new default certificate url
                if certificateUrl == oldStream.certificateUrl {
                    certificateUrl = newStream.certificateUrl
                    certificateUrlTextView.text = certificateUrl
                    // Retrieve UIScrollView to scroll to top
                    let scrollView = certificateUrlTextView.superview as? UIScrollView
                    scrollView?.contentOffset.y = 0
                }

                // Toggle license and certificate text view
                toggleTextView(textView: licenseUrlTextView, enable: !newStream.isClear)
                toggleTextView(textView: certificateUrlTextView, enable: !newStream.isClear)

                // Update stream index
                streamIndex = indexPath.row

                // Update cell check mark
                newCell.accessoryType = .checkmark
            }
        default:
            os_log("Unkown UITableView")
        }
    }
}

// MARK: - UITextViewDelegate

extension StreamConfViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Empty UITextView if current string matches the default
        switch textView {
        case videoUrlTextView:
            if let userVideoUrl = textView.text, userVideoUrl == streams[streamIndex].url {
                textView.text = ""
            }
        case licenseUrlTextView:
            if let userLicenseUrl = textView.text, userLicenseUrl == streams[streamIndex].licenseUrl {
                textView.text = ""
            }
        case certificateUrlTextView:
            if let userCertificateUrl = textView.text, userCertificateUrl == streams[streamIndex].certificateUrl {
                textView.text = ""
            }
        default:
            os_log("Unkown UITextView")
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Reset text view with default string if there is no user input.
        switch textView {
        case videoUrlTextView:
            if let userVideoUrl = textView.text, userVideoUrl != "" {
                videoUrl = userVideoUrl
            } else {
                videoUrl = streams[streamIndex].url
            }
            textView.text = videoUrl
        case licenseUrlTextView:
            if let userLicenseUrl = textView.text, userLicenseUrl != "" {
                licenseUrl = userLicenseUrl
            } else {
                licenseUrl = streams[streamIndex].licenseUrl
            }
            textView.text = licenseUrl
        case certificateUrlTextView:
            if let userCertificateUrl = textView.text, userCertificateUrl != "" {
                certificateUrl = userCertificateUrl
            } else {
                certificateUrl = streams[streamIndex].certificateUrl
            }
            textView.text = certificateUrl
        default:
            os_log("Unkown UITextView")
        }
    }
}
