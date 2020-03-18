//
//  THEOComponent.swift
//  Programmable_Stream
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

    static func textView(placeholderText: String?) -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .theoWhite
        textView.tintColor = .theoLightningYellow
        textView.autocapitalizationType = .none
        textView.font = UIFont.theoText
        textView.textColor = .theoCello
        textView.text = placeholderText

        return textView
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

    static func scrollView(useBlackIndicator: Bool = true) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = useBlackIndicator ? .black : .white

        return scrollView
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

    static func scrollableTextView(isReadOnly: Bool = false) -> (UIScrollView, UITextView) {
        let scrollView = self.scrollView()
        scrollView.backgroundColor = .theoWhite
        scrollView.layer.cornerRadius = 10.0

        let textView = self.textView(placeholderText: "")
        textView.isUserInteractionEnabled = !isReadOnly

        scrollView.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -5).isActive = true
        textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20).isActive = true

        return (scrollView, textView)
    }
}
