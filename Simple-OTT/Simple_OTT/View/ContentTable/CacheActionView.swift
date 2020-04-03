//
//  CacheActionView.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit
import UICircularProgressRing
import FontAwesome_swift

// MARK: - CacheActionViewState enumeration declaration

enum CacheActionViewState {
    case initial
    case caching
    case paused
    case cached
}

// MARK: - CacheActionView declaration

class CacheActionView: UIView {

    // MARK: - Private properties

    private var color: UIColor
    private var progressRing: UICircularProgressRing!
    private var imageView: UIImageView!
    private var imageName: FontAwesome? = nil {
        didSet {
            if let name = imageName {
                imageView.isHidden = false
                imageView.image = UIImage.fontAwesomeIcon(name: name, style: .solid, textColor: color, size: CGSize(width: 20, height: 20))
                progressRing.fontColor = .clear
            } else {
                imageView.isHidden = true
                progressRing.fontColor = color
            }
        }
    }

    // MARK: - Public properties

    var state: CacheActionViewState = .initial {
        didSet {
            switch state {
            case .initial:
                imageName = .arrowDown
                percentage = 0
            case .caching:
                imageName = nil
            case .paused:
                imageName = .pause
            case .cached:
                imageName = .trashAlt
                percentage = 100
            }
        }
    }
    var percentage: CGFloat = 0.0 {
        didSet {
            progressRing.value = percentage * 100
        }
    }

    // MARK: - View life cycle

    init(color: UIColor = .theoCello) {
        self.color = color
        super.init(frame: .zero)

        setupView()
        setupProgressRing()
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    private func setupView() {
        isUserInteractionEnabled = true
    }

    private func setupProgressRing() {
        progressRing = UICircularProgressRing()
        // Ring style
        progressRing.style = .ontop
        progressRing.startAngle = 270
        progressRing.fontColor = .clear
        progressRing.font = .boldSystemFont(ofSize: 9)

        // Inner ring settings
        progressRing.innerCapStyle = .butt
        progressRing.innerRingWidth = 3
        progressRing.innerRingColor = .theoLightningYellow

        // Outer ring settings
        progressRing.outerCapStyle = .butt
        progressRing.outerRingWidth = 3
        progressRing.outerRingColor = color

        // Ring values
        progressRing.minValue = 0
        progressRing.maxValue = 100
        progressRing.value = 0

        progressRing.translatesAutoresizingMaskIntoConstraints = false

        addSubview(progressRing)
        progressRing.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressRing.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        progressRing.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        progressRing.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func setupImageView() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        // Minus 12 on both width and height to prevent covering the progress bar
        imageView.widthAnchor.constraint(equalTo: widthAnchor, constant: -12).isActive = true
        imageView.heightAnchor.constraint(equalTo: heightAnchor, constant: -12).isActive = true
    }
}
