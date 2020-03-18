//
//  THEOComponent.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
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

    static func textButton(text: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.backgroundColor = .theoLightningYellow
        button.setTitleColor(.theoCello, for: .normal)
        button.layer.cornerRadius = 10.0
        button.setTitle(text, for: .normal)

        return button
    }

    static func switchButton(isOn: Bool = false) -> UISwitch {
        let swtichButton = UISwitch()
        swtichButton.isOn = isOn
        swtichButton.onTintColor = UIColor.theoLightningYellow.withAlphaComponent(0.5)
        swtichButton.thumbTintColor = .theoLightningYellow

        return swtichButton
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
