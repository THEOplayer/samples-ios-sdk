//
//  JsonInputViewController.swift
//  Programmable_Stream
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - JsonInputViewController declaration

class JsonInputViewController: UIViewController {

    // MARK: - Private properties

    private var titleLabel: UILabel!
    private var scrollView: UIScrollView!
    private var jsonLinkScrollView: UIScrollView!
    private var jsonLinkTextView: UITextView!
    private var loadStreamButton: UIButton!
    private var scrollViewObservation: NSKeyValueObservation!

    // View constant properties
    private let defaultJsonLink: String = "https://cdn.theoplayer.com/referenceapps/theo_drm_ad_ios.json"
    private let textViewTitle: String = "Remote JSON file:"
    private let loadStreamTitle: String = "Load Stream"

    // Property to store navigation bar title
    private var navigationBarTitle = ""
    // Link to remote json file to download
    private var jsonLink: String = ""

    // MARK: - View life cycle

    deinit {
        scrollViewObservation.invalidate()
        scrollViewObservation = nil
    }

    override func viewDidLoad() {
        setupView()
        setupScrollView()
        setupTitleLabel()
        setupScrollableTextView()
        setupLoadStreamButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        // Setup tap gesture to detect tapping outside of UITextViews
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)
    }

    private func setupScrollView() {
        scrollView = THEOComponent.scrollView()

        view.addSubview(scrollView)
        let layoutMarginsGuide = view.layoutMarginsGuide
        scrollView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
    }

    private func setupTitleLabel() {
        titleLabel = THEOComponent.label(text: textViewTitle, isTitle: true)
        titleLabel.textColor = .theoWhite

        scrollView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    }

    private func setupScrollableTextView() {
        (jsonLinkScrollView, jsonLinkTextView) = THEOComponent.scrollableTextView()

        // Flash scroll bar on content size changes
        scrollViewObservation = jsonLinkScrollView.observe(\.contentSize) { object, change in
            if object.isUserInteractionEnabled {
                object.flashScrollIndicators()
            }
        }

        jsonLink = defaultJsonLink
        jsonLinkTextView.text = jsonLink
        jsonLinkTextView.delegate = self

        scrollView.addSubview(jsonLinkScrollView)
        jsonLinkScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        jsonLinkScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        jsonLinkScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        jsonLinkScrollView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
        jsonLinkScrollView.heightAnchor.constraint(equalToConstant: (jsonLinkTextView.font!.lineHeight * 4) + 5).isActive = true
    }

    private func setupLoadStreamButton() {
        loadStreamButton = THEOComponent.textButton(text: loadStreamTitle)
        loadStreamButton.addTarget(self, action: #selector(onPlay), for: .touchUpInside)

        scrollView.addSubview(loadStreamButton)
        loadStreamButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        loadStreamButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        loadStreamButton.topAnchor.constraint(equalTo: jsonLinkScrollView.bottomAnchor, constant: 10).isActive = true
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

    @objc func onTapped() {
        // End UITextViews editing when user tapped outside of the UITextViews
        jsonLinkTextView.endEditing(true)
    }

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

    @objc private func onPlay() {
        // Reset scrollView content inset in case keyboard is still on display when button is pressed
        scrollView.contentInset = .zero

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession.init(configuration: config)

        if let url = URL(string: jsonLink) {
            session.dataTask(with: url) { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse {
                    // Check for response status
                    if response.statusCode == 200 {
                        do {
                            // Attemp to parse downloaded JSON file
                            let remoteConfig = try JSONDecoder().decode(RemoteConfig.self, from: data)
                            DispatchQueue.main.async(execute: {
                                self.pushPlayer(remoteConfig: remoteConfig)
                            })
                        } catch let error {
                            // Show parse error
                            DispatchQueue.main.async(execute: {
                                self.showError(isDownload: false, detail: error.localizedDescription)
                            })
                        }
                    } else {
                        // Show status error
                        DispatchQueue.main.async(execute: {
                            self.showError(isDownload: true, detail: "Response status: \(response.statusCode)")
                        })
                    }
                } else {
                    // Show invalid service response message
                    DispatchQueue.main.async(execute: {
                        self.showError(isDownload: true, detail: "Invalid service response")
                    })
                }
            }.resume()
        } else {
            DispatchQueue.main.async(execute: {
                self.showError(isDownload: true, detail: "Invalid URL entered")
            })
        }
    }

    // MARK: - Present error UIAlertController

    private func showError(isDownload: Bool, detail: String) {
        let alertController = UIAlertController(
            title: "Failed to \(isDownload ? "download" : "parse") JSON file",
            message: detail,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default)
        )

        self.present(alertController, animated: true)
    }

    // MARK: - Push PlayerViewController

    private func pushPlayer(remoteConfig: RemoteConfig) {
        guard self.navigationController?.topViewController as? PlayerViewController == nil else {
            // Prevent multiple player push calls
            return
        }

        let playerViewController = PlayerViewController()
        playerViewController.remoteConfig = remoteConfig
        playerViewController.navigationItem.title = navigationItem.title
        navigationItem.title = ""
        navigationController?.pushViewController(playerViewController, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension JsonInputViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Empty UITextView if current string matches the default
        if let userJsonLink = textView.text, userJsonLink == defaultJsonLink {
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Reset text view with default string if there is no user input.
        if let userJsonLink = textView.text, userJsonLink != "" {
            jsonLink = userJsonLink
        } else {
            jsonLink = defaultJsonLink
        }
        textView.text = jsonLink
    }
}
