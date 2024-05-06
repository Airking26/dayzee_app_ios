//
//  SearchVC.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import Combine

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var firstButtonLine: UIView!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var secondButtonLine: UIView!

    static  let searchBarPublisher = CurrentValueSubject<String, Never>("")
    static  let searchResignResponder = CurrentValueSubject<Bool, Never>(false)
    private var isSearchScope: Bool = false
    private var searchPagerViewController: SearchPagerViewController!
    private var cancellableBag = Set<AnyCancellable>()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchPagerViewController = segue.destination as? SearchPagerViewController {
            self.searchPagerViewController = searchPagerViewController
            searchPagerViewController.pagerControllDeleguate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SearchViewController.searchResignResponder.sink { (success) in
            guard success else { return }
            self.searchBar.resignFirstResponder()
        }.store(in: &self.cancellableBag)
        self.initUI()
    }
    
    private func initUI() {
        self.configureSearchBar()
        self.configureContainerView()
    }

    private func configureSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        self.configureScopesSearchBar(isSearchBarEmpty: self.searchBar.text?.isEmpty ?? true)
    }
    
    private func configureContainerView() {
        if !self.firstButton.isHighlighted && !isSearchScope {
            self.containerView.layer.masksToBounds = false
            self.containerView.layer.shadowColor = UIColor.black.cgColor
            self.containerView.layer.shadowRadius = 5
            self.containerView.layer.shadowOpacity = 0.25
            self.containerView.backgroundColor = .clear
        } else {
            self.containerView.layer.shadowColor = UIColor.clear.cgColor
        }
    }

    private func configureScopesSearchBar(isSearchBarEmpty: Bool) {
        self.firstButton.setTitle(isSearchBarEmpty ? Locale.current.isFrench ? "Top" : "Top" : Locale.current.isFrench ? "Comptes" : "People", for: .normal)
        self.secondButton.setTitle(isSearchBarEmpty ? Locale.current.isFrench ? "Découvrir" : "Explore" : "#", for: .normal)
        if !self.isSearchScope != isSearchBarEmpty {
            self.isSearchScope = !isSearchBarEmpty
            self.firstButtonLine.backgroundColor = .systemGray5
            self.searchPagerViewController.swipeToViewController(self.isSearchScope ? 2 : 0)
        }
        self.isSearchScope = !isSearchBarEmpty
        self.configureContainerView()
    }
    
    // MARK: - Actions

    @IBAction func firstButtonIsTapped(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.firstButtonLine.backgroundColor = .systemGray5
            self?.secondButtonLine.backgroundColor = .clear
            self?.firstButton.isHighlighted = false
            self?.secondButton.isHighlighted = true
            self?.configureContainerView()
        }
        self.searchPagerViewController.swipeToViewController(0 + (self.isSearchScope ? 2 : 0))
    }

    @IBAction func secondButtonIsTapped(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.firstButtonLine.backgroundColor = .clear
            self?.secondButtonLine.backgroundColor = .systemGray5
            self?.secondButton.isHighlighted = false
            self?.firstButton.isHighlighted = true
            self?.configureContainerView()
        }
        self.searchPagerViewController.swipeToViewController(1 + (self.isSearchScope ? 2 : 0))
    }

}

// MARK: - Searchbar delegate

extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        SearchViewController.searchBarPublisher.send(searchText)
        self.configureScopesSearchBar(isSearchBarEmpty: searchBar.text?.isEmpty ?? true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

}

// MARK: - Page controller delegate

extension SearchViewController : PagerControllDeleguate {

    func swipeToViewController(_ index: Int) {
        DispatchQueue.main.async {
            self.firstButtonLine.backgroundColor = index - (self.isSearchScope ? 2 : 0) == 0 ? .systemGray5 : .clear
            self.secondButtonLine.backgroundColor = index - (self.isSearchScope ? 2 : 0) == 0 ? .clear : .systemGray5
        }
    }

}
