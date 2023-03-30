//
//  PlayerInterfaceView.swift
//  Native_IMA
//
//  Copyright © 2023 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - PlayerInterfaceViewDelegate declaration

protocol PlayerInterfaceViewDelegate {
    func play()
    func pause()
    func skip(isForward: Bool)
    func seek(timeInSeconds: Float)
}

// MARK: - PlayerInterfaceViewState enumeration declaration

enum PlayerInterfaceViewState: Int {
    case initialise
    case buffering
    case playing
    case paused
    case adplaying
    case adpaused
}

// MARK: - PlayerInterfaceView declaration

class PlayerInterfaceView: UIView {

    // MARK: - Private properties

    private var containerView: UIView!
    private var controllerStackView: UIStackView!
    private var footerView: UIView!
    private var activityIndicatorView: UIActivityIndicatorView!
    private var playButton: UIButton!
    private var pauseButton: UIButton!
    private var skipBackwardButton: UIButton!
    private var skipForwardButton: UIButton!
    private var slider: UISlider!
    private var progressLabel: UILabel!

    // Auto hide timer variable and interval constant
    private var autoHideTimer: Timer? = nil
    private let autoHideTimeInSeconds: Double = 5.0

    // Boolean flag to show/hide the interface
    private var showInterface: Bool = true {
        didSet {
            // Start / stop auto hide timer and show / hide interface accordingly
            showInterface ? startAutoHideTimer() : stopAutoHideTimer()
            containerView.isHidden = !showInterface
        }
    }
    private var isInterfaceShowing: Bool {
        return state == .initialise || !containerView.isHidden
    }
    private var isOverHourLong: Bool = false
    private var isDraggingSlider: Bool = false
    private var durationString: String = "00:00"
    private var currentTimeString: String = "00:00" {
        didSet {
            // Update progress label when curent time string is set
            progressLabel.text = "\(currentTimeString) / \(durationString)"
        }
    }

    // Public properties

    // Display corresponding UI components based on the view state
    var state: PlayerInterfaceViewState! {
        didSet {
            stopAutoHideTimer()
            activityIndicatorView.stopAnimating()
            playButton.isHidden = true
            pauseButton.isHidden = true
            skipBackwardButton.isHidden = true
            skipForwardButton.isHidden = true
            footerView.isHidden = true
            slider.isEnabled = true
            switch state {
            case .initialise:
                containerView.isHidden = false
                currentTime = 0.0
                playButton.isHidden = false
                isDraggingSlider = false
            case .buffering:
                containerView.isHidden = false
                activityIndicatorView.startAnimating()
                skipBackwardButton.isHidden = false
                skipForwardButton.isHidden = false
                footerView.isHidden = false
            case .playing:
                startAutoHideTimer()
                pauseButton.isHidden = false
                skipBackwardButton.isHidden = false
                skipForwardButton.isHidden = false
                footerView.isHidden = false
            case .paused:
                playButton.isHidden = false
                skipBackwardButton.isHidden = false
                skipForwardButton.isHidden = false
                footerView.isHidden = false
            case .adplaying:
                startAutoHideTimer()
                pauseButton.isHidden = false
                footerView.isHidden = false
                slider.isEnabled = false
            case .adpaused:
                playButton.isHidden = false
                footerView.isHidden = false
                slider.isEnabled = false
            default:
                break
            }
        }
    }
    var duration: Float = 0.0 {
        didSet {
            // Set duration as the slider maximum value
            slider.maximumValue = duration

            isOverHourLong = (duration / 3600) >= 1
            durationString = convertTimeString(time: duration)
        }
    }
    var currentTime: Float = 0.0 {
        didSet {
            if !isDraggingSlider {
                // Update slider value
                slider.value = currentTime

                currentTimeString = convertTimeString(time: currentTime)
            }
        }
    }
    var delegate: PlayerInterfaceViewDelegate? = nil

    // MARK: - View life cycle

    init() {
        super.init(frame: .zero)

        setupView()
        setupContainerView()
        setupControllerStackView()
        setupControllerStackViewItems()
        setupFooterView()
        setupTransparentSubview()
        setupSlider()
        setupProgressLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false

        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        tapGestureReconizer.delegate = self
        self.addGestureRecognizer(tapGestureReconizer)
    }

    private func setupContainerView() {
        containerView = THEOComponent.view()

        self.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    private func setupControllerStackView() {
        controllerStackView = THEOComponent.stackView(axis: .horizontal, spacing: 40)
        controllerStackView.alignment = .center

        containerView.addSubview(controllerStackView)
        controllerStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        controllerStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        controllerStackView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor).isActive = true
        controllerStackView.heightAnchor.constraint(lessThanOrEqualTo: containerView.heightAnchor, multiplier: 0.6).isActive = true
    }

    private func setupButton(imageName: String, isLarge: Bool) -> UIButton {
        let button = THEOComponent.button(text: nil, image: UIImage(named: imageName))
        button.backgroundColor = .clear

        controllerStackView.addArrangedSubview(button)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: isLarge ? 100 : 60).isActive = true

        return button
    }

    private func setupActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)

        controllerStackView.addArrangedSubview(activityIndicatorView)
        activityIndicatorView.widthAnchor.constraint(equalTo: activityIndicatorView.heightAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }

    private func setupControllerStackViewItems() {
        skipBackwardButton = setupButton(imageName: "skip-backward", isLarge: false)
        skipBackwardButton.addTarget(self, action: #selector(onSkipBackward), for: .touchUpInside)

        setupActivityIndicatorView()

        playButton = setupButton(imageName: "play", isLarge: true)
        playButton.addTarget(self, action: #selector(onPlay), for: .touchUpInside)

        pauseButton = setupButton(imageName: "pause", isLarge: true)
        pauseButton.addTarget(self, action: #selector(onPause), for: .touchUpInside)

        skipForwardButton = setupButton(imageName: "skip-forward", isLarge: false)
        skipForwardButton.addTarget(self, action: #selector(onSkipForward), for: .touchUpInside)
    }

    private func setupFooterView() {
        footerView = THEOComponent.view()
        footerView.backgroundColor = .clear
        footerView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        containerView.addSubview(footerView)
        footerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        footerView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    private func setupTransparentSubview() {
        let view = THEOComponent.view()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)

        footerView.addSubview(view)
        view.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: footerView.bottomAnchor).isActive = true
    }

    private func setupSlider() {
        slider = THEOComponent.slider()
        // Add callback to monitor valueChanged
        slider.addTarget(self, action: #selector(onSliderValueChange), for: .valueChanged)
        // Add tap gesture recognizer to the slider to support tap to set value
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSliderTapped))
        slider.addGestureRecognizer(tapGestureRecognizer)

        footerView.addSubview(slider)
        let layoutMarginsGuide = footerView.layoutMarginsGuide
        slider.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        slider.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
    }

    private func setupProgressLabel() {
        progressLabel = THEOComponent.label(text: "00:00 / 00:00")
        progressLabel.textColor = .theoWhite
        progressLabel.textAlignment = .center

        footerView.addSubview(progressLabel)
        progressLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        let layoutMarginsGuide = footerView.layoutMarginsGuide
        progressLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        progressLabel.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor).isActive = true
        progressLabel.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: 10).isActive = true
    }

    // MARK: - Util function to convert time string

    private func convertTimeString(time: Float) -> String {
        let seconds = Int(time)
        let (hour, mim, sec) = ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))

        if isOverHourLong {
            return String(format: "%02d:%02d:%02d", hour, mim, sec)
        } else {
            return String(format: "%02d:%02d", mim, sec)
        }
    }

    // MARK: - Start/stop auto hide timer

    private func stopAutoHideTimer() {
        guard autoHideTimer != nil else { return }
        autoHideTimer?.invalidate()
        autoHideTimer = nil
    }

    private func startAutoHideTimer() {
        // Always terminate previous timer
        stopAutoHideTimer()
        // Create new timer
        autoHideTimer =  Timer.scheduledTimer(withTimeInterval: autoHideTimeInSeconds, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.showInterface = false
        }
    }

    // MARK: - Gesture callback

    @objc private func onTapped(sender: UITapGestureRecognizer) {
        // Placeholder. All tap logics are handled in the shouldReceive callback of gestureRecognizer
    }

    // MARK: - Button callbacks

    @objc private func onSkipBackward() {
        showInterface = true
        delegate?.skip(isForward: false)
    }

    @objc private func onPlay() {
        showInterface = true
        delegate?.play()
    }

    @objc private func onPause() {
        showInterface = true
        delegate?.pause()
    }

    @objc private func onSkipForward() {
        showInterface = true
        delegate?.skip(isForward: true)
    }

    // MARK: - Slider callbacks

    @objc private func onSliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let tappedPoint: CGPoint = gestureRecognizer.location(in: self)
        let xOffset: CGFloat = tappedPoint.x - slider.frame.origin.x
        var tappedValue: Float = 0.0
        // X offset can not be smaller than 0
        if xOffset > 0 {
            // Multiply current X offset to the 'max value' : 'width' ratio to work out the tapped value
            tappedValue = Float((xOffset * CGFloat(slider.maximumValue) / slider.frame.size.width))
        }

        showInterface = true
        slider.setValue(tappedValue, animated: true)
        delegate?.seek(timeInSeconds: tappedValue)
    }

    @objc private func onSliderValueChange(slider: UISlider, event: UIEvent) {
        if let touch = event.allTouches?.first {
            switch touch.phase {
            case .began:
                isDraggingSlider = true
                showInterface = true
                // Stop timer to prevent auto hide during dragging
                stopAutoHideTimer()
            case .moved:
                // Update time label to reflect the dragged time
                currentTimeString = convertTimeString(time: slider.value)
            case .ended:
                isDraggingSlider = false
                delegate?.seek(timeInSeconds: slider.value)
            default:
                break
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PlayerInterfaceView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        /* UIStackView is non-drawing view and controllerStackView
            covers big part of the screen which can be tapped by user
            easily. Since touch event for items on controllerStackView
            will be handled with their own handler; tapping
            controllerStackView will be considered as tapping the
            controller interface view
         */
        let isControlViewTapped = (touch.view == containerView || touch.view == controllerStackView)
        // Toggle to show/hide interface is only needed in the playing state. The interface stays on for other states
        if state == .playing || state == .adplaying {
            if isInterfaceShowing && isControlViewTapped {
                // If interface is currently showing and user tapped on empty area, hide interface and stop auto hide timer
                showInterface = false
            } else {
                // Else show interface and set auto hide timer
                showInterface = true
            }
        }
        return isControlViewTapped
    }
}
