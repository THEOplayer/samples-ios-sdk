//
//  THEOComponent.swift
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import UIKit


// MARK: - THEO components creator

class THEOComponent {
    static func view() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }

    static func label(text: String?, isTitle: Bool = false) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = isTitle ? .theoTitle : .theoText
        label.textColor = .theoCello
        label.text = text

        return label
    }

    static func button(text: String?, image: UIImage?) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .theoLightningYellow

        if let _ = text {
            button.setTitle(text, for: .normal)
        }
        if let _ = image {
            button.setImage(image, for: .normal)
        }

        return button
    }

    static func slider() -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = .theoLightningYellow
        slider.thumbTintColor = .theoLightningYellow
        slider.maximumValue = 1.0

        return slider
    }

    static func progressView(height: CGFloat = 10.0) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.backgroundColor = .theoCello
        progressView.progressTintColor = .theoLightningYellow
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = height / 2
        progressView.heightAnchor.constraint(equalToConstant: height).isActive = true

        return progressView
    }

    static func tableView(useBlackIndicator: Bool = true) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bounces = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = useBlackIndicator ? .black : .white

        return tableView
    }

    static func stackView(axis: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 20.0) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.axis = axis
        stackView.distribution = .equalSpacing
        stackView.spacing = spacing

        return stackView
    }
    
    static func liveButton(isLive: Bool = false) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear

        // Store the live state in the button's tag or create a custom property
        button.tag = isLive ? 1 : 0

        // Set initial state
        updateLiveButtonState(button: button, isLive: isLive)

        // Add target for button tap
        button.addTarget(button, action: #selector(UIButton.liveButtonTapped), for: .touchUpInside)

        return button
    }

    static func updateLiveButtonState(button: UIButton, isLive: Bool) {
        let attributedString = NSMutableAttributedString()

        // Determine colors based on state
        let dotColor = isLive ? UIColor.systemRed : UIColor.systemGray
        let textColor = isLive ? UIColor.theoCello : UIColor.systemGray
        let text = "LIVE"

        // Add dot
        let dot = NSAttributedString(string: "● ", attributes: [
            .foregroundColor: dotColor,
            .font: UIFont.systemFont(ofSize: 12)
        ])

        // Add text
        let liveText = NSAttributedString(string: text, attributes: [
            .foregroundColor: textColor,
            .font: UIFont.theoText
        ])

        attributedString.append(dot)
        attributedString.append(liveText)

        button.setAttributedTitle(attributedString, for: .normal)

        // Update the tag to reflect current state
        button.tag = isLive ? 1 : 0
    }
    
}

extension UIButton {
    @objc fileprivate func liveButtonTapped() {
        let currentState = self.tag == 1
        let newState = !currentState
        THEOComponent.updateLiveButtonState(button: self, isLive: newState)
    }
    
    var isLive: Bool {
        set { THEOComponent.updateLiveButtonState(button: self, isLive: newValue) }
        get { self.tag == 1 }
    }
}

