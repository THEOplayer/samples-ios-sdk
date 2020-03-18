//
//  GradientView.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - GradientView declaration

// Setup gradient layer in a custom class so that gradient layer will be updated by auto layout
class GradientView: UIView {
    // Override the layerClass as a CAGradientLayer
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    init() {
        super.init(frame: .zero)

        setupGradientLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGradientLayer() {
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }

        gradientLayer.colors = [UIColor.theoCello.cgColor, UIColor.theoLinkWater.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
    }
}
