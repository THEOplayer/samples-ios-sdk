//
//  THEOComponent.swift
//  Offline_Playback
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
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
}
