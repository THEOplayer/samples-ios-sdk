//
//  TabbedMetadataView.swift
//  Programmable_Stream
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - MetadataType enumeration declaration

enum MetadataType: String, CaseIterable {
    case tracksInfo = "Tracks Info"
    case timeInfo = "Time Info"
    case stateAndLogs = "State & Logs"
    case ads = "Ads"
}

// MARK: - TabbedMetadataView declaration

class TabbedMetadataView: UIView {

    // MARK: - Private properties

    private var tabBarControl: TabBarControl!
    private var scrollView: UIScrollView!
    private var textView: UITextView!

    // ScrollView observation and flag for auto scroll support
    private var scrollViewObservation: NSKeyValueObservation!
    private var isScrollViewDragging: Bool = false

    private var metadataDict: [MetadataType : String] = [
        .timeInfo : "",
        .tracksInfo : "",
        .stateAndLogs : "",
        .ads : ""
    ]

    var selectedType: MetadataType {
        get {
            return MetadataType.allCases[tabBarControl.currentIndex]
        }
    }

    // MARK: - View life cycle

    init() {
        super.init(frame: .zero)

        setupView()
        setupTabBarControl()
        setupScrollableTextView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func deInit() {
        // Free UIScrollView content size obversations
        scrollViewObservation.invalidate()
        scrollViewObservation = nil
    }

    // MARK: - View setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .theoWhite
    }

    private func setupTabBarControl() {
        let metadataList = MetadataType.allCases.map{return $0.rawValue}
        tabBarControl = TabBarControl(tabNames: metadataList)
        tabBarControl.addTarget(self, action: #selector(onTabBarControlValueChanged), for: .valueChanged)

        self.addSubview(tabBarControl)
        tabBarControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        tabBarControl.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tabBarControl.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    private func setupScrollableTextView() {
        (scrollView, textView) = THEOComponent.scrollableTextView(isReadOnly: true)
        scrollView.delegate = self

        // Observe changes on scrollview contentSize and auto scroll
        scrollViewObservation = scrollView.observe(\.contentSize) { scrollView, change in
            // Only auto scroll when the metadata scrollView content is scrollable and is not dragged by user
            if scrollView.isUserInteractionEnabled &&
                !self.isScrollViewDragging &&
                self.scrollView.contentSize.height >= self.scrollView.bounds.size.height {
                scrollView.flashScrollIndicators()
                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                self.scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }

        self.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: tabBarControl.bottomAnchor, constant: 10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    // MARK: - Value changed handler for TabBarControl

    @objc private func onTabBarControlValueChanged() {
        textView.text = metadataDict[selectedType]!
    }

    // MARK: - Store and display metadata by type

    func setMetadata(type: MetadataType, dataStr: String, isAppending: Bool = true) {
        if isAppending {
            metadataDict[type]! += "\(dataStr)\n"
        } else {
            metadataDict[type]! = "\(dataStr)\n"
        }

        textView.text = metadataDict[selectedType]!
        if selectedType == type {
            textView.text = metadataDict[type]!
        }
    }

    // MARK: - Reset component and data

    func reset() {
        metadataDict = [
            .timeInfo : "",
            .tracksInfo : "",
            .stateAndLogs : "",
            .ads : ""
        ]
        textView.text = ""
        tabBarControl.currentIndex = 0
    }
}

// MARK: - UIScrollViewDelegate

extension TabbedMetadataView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrollViewDragging = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrollViewDragging = false
    }
}
