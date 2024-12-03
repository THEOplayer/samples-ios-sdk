//
//  THEOPlayerView.swift
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import UIKit

class THEOPlayerView: UIView {
    // MARK: - Type alias

    // Closure that provides latest frame when layout is updated
    typealias frameUpdatedClosure = (CGRect) -> Void

    // MARK: - Private property

    private var frameUpdated: frameUpdatedClosure? = nil

    // MARK: - Convenience initializer

    convenience init(frameUpdated: @escaping frameUpdatedClosure) {
        self.init()
        // Store provided closure in private property
        self.frameUpdated = frameUpdated
    }

    // MARK: - View layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // Call frameUpdated closure with the latest frame
        frameUpdated?(frame)
    }

    func setConstraintsToSafeArea(safeArea: UILayoutGuide) {
        // Position playerView at the center of the safe area
        self.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        // Set width and height using the width and height of the safe area
        self.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: safeArea.heightAnchor).isActive = true
    }
}
