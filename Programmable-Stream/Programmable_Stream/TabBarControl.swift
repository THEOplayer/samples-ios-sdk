//
//  TabBarControl.swift
//  Programmable_Stream
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - TabBarControl declaration

// Subclassing UIControl to be able to send valueChanged event
class TabBarControl: UIControl {

    // MARK: - Private properties

    private var stackView: UIStackView!
    private var tabLabels: [UILabel] = [UILabel]()
    private var selector: UIView!
    // Constraint that moves selector horizontally
    private var selectorLeadingConstraint: NSLayoutConstraint!

    // View constant properties
    private let stackViewSpace: CGFloat = 10
    private let selectorHeight: CGFloat = 3

    // Internal index to track current tab selection
    private var tabIndex: Int = 0

    // UI appearance properties
    private var backgroundViewColour: UIColor
    private var labelColour: UIColor
    private var highLightSelectedLabel: Bool
    private var selectorColour: UIColor

    // MARK: - Public properties

    var tabNames: [String] {
        didSet {
            // Reset index to 0
            currentIndex = 0

            // Remove selector
            selector.removeFromSuperview()

            //Remove old labels
            for subview in stackView.arrangedSubviews {
                subview.removeFromSuperview()
                stackView.removeArrangedSubview(subview)
            }

            // Empty label array
            tabLabels = [UILabel]()

            // Setup label and selector again
            setupTabLabels()
            setupSelector()
        }
    }

    var currentIndex: Int {
        get {
            // Getter returns tabIndex
            return tabIndex
        }
        set(newIndex) {
            // Setter check new index value and then use onLabelTapped to update UI and tabIndex
            if newIndex <= tabLabels.count,
                let gestureRecognizers = tabLabels[newIndex].gestureRecognizers,
                gestureRecognizers.count > 0 {
                onLabelTapped(sender: gestureRecognizers[0] as! UITapGestureRecognizer)
            }
        }
    }

    // MARK: - View life cycle

    init(tabNames: [String], highLightSelectedLabel: Bool = false, backgroundColour: UIColor = .clear, labelColour: UIColor = .theoCello, selectorColor: UIColor = .theoLightningYellow) {
        self.tabNames = tabNames
        self.backgroundViewColour = backgroundColour
        self.labelColour = labelColour
        self.highLightSelectedLabel = highLightSelectedLabel
        self.selectorColour = selectorColor
        super.init(frame: .zero)

        setupView()
        setupStackView()
        setupTabLabels()
        setupSelector()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = backgroundViewColour
        // Extra bottom space for selector
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    private func setupStackView() {
        stackView = THEOComponent.stackView(axis: .horizontal, spacing: stackViewSpace)
        stackView.distribution = .fillEqually

        self.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        // Avoid overlap with selector
        stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -selectorHeight).isActive = true
        stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        // Set minimum height to prevent difficult tab tapping
        stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
    }

    private func setupTabLabels() {
        for (index, tabName) in tabNames.enumerated() {
            let label = THEOComponent.label(text: tabName)
            label.font = UIFont.boldSystemFont(ofSize: 13)
            label.isUserInteractionEnabled = true
            label.textAlignment = .center
            label.numberOfLines = 0
            if highLightSelectedLabel {
                label.textColor = index == tabIndex ? labelColour : labelColour.withAlphaComponent(0.5)
            } else {
                label.textColor = labelColour
            }

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onLabelTapped))
            label.addGestureRecognizer(tapGesture)

            tabLabels.append(label)
            stackView.addArrangedSubview(label)
        }
    }

    private func setupSelector() {
        selector = THEOComponent.view()
        selector.backgroundColor = selectorColour
        selector.layer.cornerRadius = selectorHeight / 2

        self.addSubview(selector)
        selector.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        selector.heightAnchor.constraint(equalToConstant: selectorHeight).isActive = true

        if tabLabels.count > 0 {
            // StackView will distribute equally, so all labels will have the same size
            selector.widthAnchor.constraint(equalTo: tabLabels[0].widthAnchor).isActive = true
            // Initialise leading constraint to the first label and keeping reference
            selectorLeadingConstraint = selector.leadingAnchor.constraint(equalTo: tabLabels[0].leadingAnchor)
            selectorLeadingConstraint.isActive = true
        }
    }

    // MARK: - Tap handler that updates index and fire value changed event

    @objc private func onLabelTapped(sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel,
            let newIndex = tabLabels.firstIndex(of: label),
            newIndex != currentIndex {

            if highLightSelectedLabel {
                let oldLabel = tabLabels[tabIndex]
                oldLabel.textColor = labelColour.withAlphaComponent(0.5)
            }
            label.textColor = labelColour

            // Update index
            tabIndex = newIndex

            // Update selector leading constraint
            selectorLeadingConstraint.isActive = false
            selector.removeConstraint(selectorLeadingConstraint)
            selectorLeadingConstraint = selector.leadingAnchor.constraint(equalTo: label.leadingAnchor)
            selectorLeadingConstraint.isActive = true

            // Animate the selector movement
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }

            // Send value changed event to notify listener
            sendActions(for: UIControl.Event.valueChanged)
        }
    }
}
