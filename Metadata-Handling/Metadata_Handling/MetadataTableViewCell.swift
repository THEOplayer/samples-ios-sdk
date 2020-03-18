//
//  MetadataTableViewCell.swift
//  Metadata_Handling
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - MetadataTableViewCell declaration

class MetadataTableViewCell: UITableViewCell {

    // MARK: - Private properties

    private var containerView: UIView!
    private var hStackView: UIStackView!
    private var streamNameLabel: UILabel!
    private var arrowImageView: UIImageView!

    // MARK: - Public property

    var stream: Stream? {
        didSet {
            if let stream = stream {
                streamNameLabel.text = stream.name
            }
        }
    }

    // MARK: - View life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setupView()
        setupContainerView()
        setupStackView()
        setupStreamNameLabel()
        setupArrowImageView()
        setupSeparator()
    }

    // MARK: - View setup

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear

        detailTextLabel?.font = UIFont.theoText
        detailTextLabel?.textColor = .theoCello
    }

    private func setupContainerView() {
        containerView = THEOComponent.view()

        containerView.backgroundColor = .theoWhite
        containerView.layer.cornerRadius = 10
        containerView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        contentView.addSubview(containerView)

        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    }

    private func setupStackView() {
        hStackView = THEOComponent.stackView(axis: .horizontal, spacing: 10)

        containerView.addSubview(hStackView)

        let layoutMarginsGuide = containerView.layoutMarginsGuide
        hStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        hStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        hStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        hStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
    }

    private func setupStreamNameLabel() {
        streamNameLabel = THEOComponent.label(text: "")
        hStackView.addArrangedSubview(streamNameLabel)
    }

    private func setupArrowImageView() {
        arrowImageView = UIImageView(image: UIImage(named: "arrowForwardBlack"))
        hStackView.addArrangedSubview(arrowImageView)
    }

    private func setupSeparator() {
        let separator = THEOComponent.view()

        contentView.addSubview(separator)
        separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10.0).isActive = true
    }
}
