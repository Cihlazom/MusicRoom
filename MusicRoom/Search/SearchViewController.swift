//
//  SearchViewController.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchDisplayLogic: AnyObject {
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {
    
    var interactor: SearchBusinessLogic?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    private var timer: Timer?
    private var searchViewModel = SearchViewModel.init(cells: [])
    private lazy var footerView = FooterView()
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    // MARK: Setup
    
    private func setup() {
        let viewController        = self
        let interactor            = SearchInteractor()
        let presenter             = SearchPresenter()
        viewController.interactor = interactor
        interactor.presenter      = presenter
        presenter.viewController  = viewController
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
        setupSearchBar()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TrackCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = footerView
    }
    
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayTracks(let searchViewModel):
            self.searchViewModel = searchViewModel
            tableView.reloadData()
            footerView.hideLoader()
        case .displayFooterView:
            footerView.showLoader()
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as! TrackCell
        let cellViewModel = searchViewModel.cells[indexPath.row]
        cell.trackImageView.backgroundColor = .systemRed
        cell.set(viewModel: cellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter search term above"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchViewModel.cells.count > 0 ? 0 : 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
        tabBarVC?.trackDetailView.delegate = self
        
        let cellViewModel = searchViewModel.cells[indexPath.row]
        self.tabBarDelegate?.maximizeTrackDetails(viewModel: cellViewModel)
        
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            self.interactor?.makeRequest(request: Search.Model.Request.RequestType.getTracks(searchTerm: searchText))
        })
    }
}

// MARK: - TrackMovingDelegate

extension SearchViewController: TrackMovingDelegate {
    
    private func getTrack(isForward: Bool) -> SearchViewModel.Cell? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        tableView.deselectRow(at: indexPath, animated: true)
        var nextIndexPath: IndexPath!
        if isForward {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == searchViewModel.cells.count {
                nextIndexPath.row = 0
            }
        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row == -1 {
                nextIndexPath.row = searchViewModel.cells.count - 1
            }
        }
        
        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        let cellViewModel = searchViewModel.cells[nextIndexPath.row]
        return cellViewModel
    }
    
    func moveBack() -> SearchViewModel.Cell? {
        return getTrack(isForward: false)
    }
    
    func moveForward() -> SearchViewModel.Cell? {
        return getTrack(isForward: true)
    }
}
