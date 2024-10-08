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

    static func stackView(axis: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 20.0) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.axis = axis
        stackView.distribution = .equalSpacing
        stackView.spacing = spacing

        return stackView
    }
}
