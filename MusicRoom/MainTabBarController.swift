//
//  MainTabBarController.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//

import UIKit
import SwiftUI

protocol MainTabBarControllerDelegate: AnyObject {
    func minimizeTrackDetails()
    func maximizeTrackDetails(viewModel: SearchViewModel.Cell?)
}

class MainTabBarController: UITabBarController {
    
    let searchVc = SearchViewController()
    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        tabBar.tintColor = .red
        
        searchVc.tabBarDelegate = self
        var library = Library()
        library.tabBarDelegate = self
        let hostVc = UIHostingController(rootView: library)
        hostVc.tabBarItem.image = UIImage(systemName: "music.note.list")
        hostVc.tabBarItem.title = "Library"
        
        setupTrackDetailView()
        viewControllers = [
            generateViewController(rootViewController: searchVc, image: "magnifyingglass", title: "Search"),
            hostVc
        ]
    }
    
    private func generateViewController(rootViewController: UIViewController, image: String, title: String) -> UIViewController {
        let navVc = UINavigationController(rootViewController: rootViewController)
        navVc.tabBarItem.image = UIImage(systemName: image)
        navVc.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navVc.navigationBar.prefersLargeTitles = true
        return navVc
    }
    
    private func setupTrackDetailView() {
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVc
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant:  view.frame.height)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        
        maximizedTopAnchorConstraint.isActive = true
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }
}

extension MainTabBarController: MainTabBarControllerDelegate {
    
    func maximizeTrackDetails(viewModel: SearchViewModel.Cell?) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 0
            self.trackDetailView.miniTrackView.alpha = 0
            self.trackDetailView.maximizedStackView.alpha = 1
        }
        
        guard let viewModel = viewModel else {
            return
        }
        self.trackDetailView.set(viewModel: viewModel)
    }
    
    func minimizeTrackDetails() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 1
            self.trackDetailView.miniTrackView.alpha = 1
            self.trackDetailView.maximizedStackView.alpha = 0
        }
    }
}
