//
//  SimpleOTTViewController.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import UIKit

// MARK: - SimpleOTTViewController declaration

class SimpleOTTViewController: UIViewController {

    // MARK: - Private properties

    private var tabBarControl: TabBarControl!
    private var viewControllers: [UIViewController] = [UIViewController]()
    private var viewModel: SimpleOTTViewViewModel

    // MARK: - View life cycle

    init(viewModel: SimpleOTTViewViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        // Populate view controller array with content tables and setting
        self.populateTabViewControllers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupGradientView()
        setupTabBarControl()

        // Add initial view controller
        addChildViewController(viewController: viewControllers[0])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true
        navigationItem.title = ""
    }

    private func populateTabViewControllers() {
        for contentTableViewVM in viewModel.contentTableViewVMs {
            viewControllers.append(ContentTableViewController(viewModel: contentTableViewVM))
        }
        viewControllers.append(SettingsViewController(viewModel: viewModel.settingViewVM))
    }

    // MARK: - View setup

    private func setupView() {
        view.backgroundColor = .theoCello

        // Setup left and right swipe gesture handlers
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeGesture))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeGesture))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    private func setupGradientView() {
        let safeArea = view.safeAreaLayoutGuide
        let gradientView = GradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(gradientView)
        gradientView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        gradientView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
    }

    private func setupTabBarControl() {
        tabBarControl = TabBarControl(tabNames: viewModel.tabNames, highLightSelectedLabel: true, backgroundColour: UIColor.theoWhite.withAlphaComponent(0.2), labelColour: .theoWhite, selectorColor: .theoLightningYellow)
        tabBarControl.addTarget(self, action: #selector(onTabBarControlValueChanged), for: .valueChanged)

        view.addSubview(tabBarControl)
        let safeArea = view.safeAreaLayoutGuide
        tabBarControl.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tabBarControl.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        tabBarControl.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
    }

    // MARK: - Container functions that add and remove children view controllers

    private func addChildViewController(viewController: UIViewController) {
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.navigationItem.title = ""

        view.addSubview(viewController.view)

        viewController.view.topAnchor.constraint(equalTo: tabBarControl.bottomAnchor).isActive = true
        let safeArea = view.safeAreaLayoutGuide
        viewController.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true

        viewController.willMove(toParent: nil)
    }

    private func removeChildViewController(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    // MARK: - TabBarControl handler

    @objc private func onTabBarControlValueChanged() {
        if tabBarControl.currentIndex <= viewControllers.count {
            // Remove current child view controller and add the one indexed by the tabBarControl index
            removeChildViewController(viewController: children.last!)
            addChildViewController(viewController: viewControllers[tabBarControl.currentIndex])
        }
    }

    // MARK: - Swipe gesture handler

    @objc private func onSwipeGesture(gesture: UISwipeGestureRecognizer) -> Void {
        // Set tabBarControl.currentIndex on swipe which will trigger onTabBarControlValueChanged() and update child view controller
        if gesture.direction == .left && tabBarControl.currentIndex < viewControllers.count - 1 {
            tabBarControl.currentIndex += 1
        }
        else if gesture.direction == .right && tabBarControl.currentIndex > 0{
            tabBarControl.currentIndex -= 1
        }
    }
}
