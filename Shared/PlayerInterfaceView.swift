//
//  PlayerInterfaceView.swift
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import UIKit
import CoreMedia

// MARK: - PlayerInterfaceViewDelegate declaration

protocol PlayerInterfaceViewDelegate: AnyObject {
    func play()
    func pause()
    func skip(isForward: Bool)
    func seek(timeInSeconds: Float)
    func toggleMute()
}

// MARK: - PlayerInterfaceViewState enumeration declaration

enum PlayerInterfaceViewState: Int {
    case initialise
    case buffering
    case playing
    case paused
    case adplaying
    case adpaused
    case muted
    case nonmuted
}

// MARK: - PlayerInterfaceView declaration

class PlayerInterfaceView: UIView {
    
    // MARK: - Constants
    private static let LIVE_THRESHOLD: Float = 10.0

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
    private var sliderContainer: UIView!
    private var muteButton: UIButton!
    private var liveButton: UIButton!
    private var progressLabel: UILabel!
    private var progressLabelLeadingConstraint: NSLayoutConstraint!
    private var liveButtonLeadingConstraint: NSLayoutConstraint!

    // Auto hide timer variable and interval constant
    private var autoHideTimer: Timer? = nil
    private let autoHideTimeInSeconds: Double = 3.0

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
    
    var seekableRange: CMTimeRange = .zero {
        didSet {
            // Set duration as the slider maximum value
            slider.maximumValue = Float(seekableRange.duration.seconds)
            isOverHourLong = (seekableRange.duration.seconds / 3600) >= 1
        }
    }
    
    private var isOverHourLong: Bool = false
    private var isDraggingSlider: Bool = false
    private var isLive: Bool = false
    private var durationString: String = "00:00"
    private var currentTimeString: String = "00:00" {
        didSet {
            if isLive {
                progressLabel.text = "\(currentTimeString)"
                return
            }
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
            if duration == .infinity {
                liveButton.isHidden = false
                progressLabel.isHidden = true
                progressLabelLeadingConstraint.isActive = false
                liveButtonLeadingConstraint.isActive = true
                isLive = true
            } else {
                liveButton.isHidden = true
                progressLabel.isHidden = false
                liveButtonLeadingConstraint.isActive = false
                progressLabelLeadingConstraint.isActive = true
                isLive = false
                durationString = convertTimeString(time: duration)
            }
        }
    }
    
    var currentTime: Float = 0.0 {
        didSet {
            if !isDraggingSlider {
                // Update slider value
                if isLive {
                    let showableCurrentTime = Float(seekableRange.end.seconds) - currentTime
                    slider.value = showableCurrentTime
                    
                    if showableCurrentTime < PlayerInterfaceView.LIVE_THRESHOLD {
                        // At live edge - show only LIVE button
                        liveButton.isLive = true
                        progressLabel.isHidden = true
                        progressLabelLeadingConstraint.isActive = false
                        liveButtonLeadingConstraint.isActive = true
                        currentTimeString = ""
                    } else {
                        // Behind live - show LIVE button + offset in progress label to the right
                        liveButton.isLive = false
                        progressLabel.isHidden = false
                        liveButtonLeadingConstraint.isActive = true
                        progressLabelLeadingConstraint.isActive = false
                        
                        // Update progress label constraint to anchor to liveButton
                        NSLayoutConstraint.deactivate([progressLabelLeadingConstraint])
                        progressLabelLeadingConstraint = progressLabel.leadingAnchor.constraint(equalTo: liveButton.trailingAnchor, constant: 10)
                        progressLabelLeadingConstraint.isActive = true
                        
                        currentTimeString = "-\(convertTimeString(time: showableCurrentTime))"
                    }
                } else {
                    let showableCurrentTime = currentTime - Float(seekableRange.start.seconds)
                    currentTimeString = convertTimeString(time: showableCurrentTime)
                }
                slider.value = currentTime - Float(seekableRange.start.seconds)
            }
        }
    }
    
    weak var delegate: PlayerInterfaceViewDelegate? = nil

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
        setupMuteButton()
        setupLiveButtonLabel()
        setupProgressLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setConstraintsToSafeArea(safeArea: UILayoutGuide) {
        // Position PlayerInterfaceView at the center of the safe area
        self.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        // Set width and height using the width and height of the safe area
        self.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: safeArea.heightAnchor).isActive = true
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
        controllerStackView = THEOComponent.stackView(axis: .horizontal, spacing: 60)
        controllerStackView.alignment = .center

        containerView.addSubview(controllerStackView)
        controllerStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        controllerStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        controllerStackView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor).isActive = true
        controllerStackView.heightAnchor.constraint(lessThanOrEqualTo: containerView.heightAnchor, multiplier: 0.6).isActive = true
    }

    private func setupButton(imageName: String, isLarge: Bool) -> UIButton {
        let button = THEOComponent.button(text: nil, image: UIImage(named: imageName))
        button.tintColor = .white
        button.backgroundColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        
        if let imageView = button.imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: isLarge ? 80 : 55),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
            ])
        }
        
        controllerStackView.addArrangedSubview(button)
        
        return button
    }

    private func setupActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(style: .large)

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
        footerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
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
        // Create slider container with grey background
        sliderContainer = THEOComponent.view()
        sliderContainer.backgroundColor = UIColor(white: 0.3, alpha: 0.2)
        sliderContainer.layer.cornerRadius = 4
        
        footerView.addSubview(sliderContainer)
        let layoutMarginsGuide = footerView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            sliderContainer.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            sliderContainer.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            sliderContainer.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            sliderContainer.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        slider = THEOComponent.slider()
        // Add callback to monitor valueChanged
        slider.addTarget(self, action: #selector(onSliderValueChange), for: .valueChanged)
        // Add tap gesture recognizer to the slider to support tap to set value
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSliderTapped))
        slider.addGestureRecognizer(tapGestureRecognizer)

        sliderContainer.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: sliderContainer.leadingAnchor, constant: 10),
            slider.trailingAnchor.constraint(equalTo: sliderContainer.trailingAnchor, constant: -10),
            slider.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor)
        ])
    }

    private func setupMuteButton() {
        let volumeHighImage = UIImage(named: "volume-high")?.withRenderingMode(.alwaysTemplate)
        muteButton = THEOComponent.button(text: nil, image: volumeHighImage)
        muteButton.tintColor = .white
        muteButton.backgroundColor = .clear
        muteButton.isUserInteractionEnabled = true // Explicitly enable interaction
        muteButton.addTarget(self, action: #selector(onMuteButtonTapped), for: .touchUpInside)

        footerView.addSubview(muteButton)
        let layoutMarginsGuide = footerView.layoutMarginsGuide

        NSLayoutConstraint.activate([
            muteButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            muteButton.topAnchor.constraint(equalTo: sliderContainer.bottomAnchor, constant: 5),
            muteButton.widthAnchor.constraint(equalToConstant: 30),
            muteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    public func updateMuteButton(isMuted: Bool) {
        let imageName = isMuted ? "volume-off" : "volume-high"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        muteButton.setImage(image, for: .normal)
        muteButton.tintColor = .white
    }

    private func setupProgressLabel() {
        progressLabel = THEOComponent.label(text: "00:00 / 00:00")
        progressLabel.textColor = .dolbyWhite
        progressLabel.textAlignment = .left

        footerView.addSubview(progressLabel)
        progressLabelLeadingConstraint = progressLabel.leadingAnchor.constraint(equalTo: muteButton.trailingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            progressLabel.centerYAnchor.constraint(equalTo: muteButton.centerYAnchor)
        ])
    }
    
    private func setupLiveButtonLabel() {
        liveButton = THEOComponent.liveButton()
        liveButton.isHidden = true
        liveButton.addTarget(self, action: #selector(onLiveButtonTapped), for: .touchUpInside)

        footerView.addSubview(liveButton)
        liveButtonLeadingConstraint = liveButton.leadingAnchor.constraint(equalTo: muteButton.trailingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            liveButton.centerYAnchor.constraint(equalTo: muteButton.centerYAnchor)
        ])
    }

    // MARK: - Util function to convert time string

    private func convertTimeString(time: Float) -> String {
        guard time > 0 else { return "00:00" }
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
    
    @objc private func onLiveButtonTapped() {
        delegate?.seek(timeInSeconds: .infinity)
    }
    
    @objc private func onMuteButtonTapped() {
        showInterface = true
        delegate?.toggleMute()
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
                if isLive {
                    let value = slider.maximumValue - slider.value
                    currentTimeString = "-\(convertTimeString(time: value))"
                } else {
                    currentTimeString = convertTimeString(time: slider.value)
                }
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
