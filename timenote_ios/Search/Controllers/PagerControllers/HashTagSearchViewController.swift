//
//  HashTagSearchViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 8/3/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import Combine
import UIKit


typealias HashTagDataSource  = UITableViewDiffableDataSource<Section, TimenoteDataDto>
typealias HashTagSnapShot    = NSDiffableDataSourceSnapshot<Section, TimenoteDataDto>


class HashTagSearchViewController : UITableViewController {
    
    static let TimenoteListCell : String    = "TimenoteWithHeaderXibView"
    
    /* VARIABLES */
    private var cancellableBag      : Set<AnyCancellable>   = Set<AnyCancellable>()

    private var searchBarText       : String                = "" { didSet {
        TimenoteManager.shared.getByTag(tag: self.searchBarText)
    }}
    private var timenotesSearched           : [TimenoteDataDto] = [] { didSet {
        self.updateHashTagUI()
    }}
    private var timenoteDetailSelected      : TimenoteDataDto?  = nil
    private var timenotCommentSelected      : Bool              = false
    
    private var hashTagDataSource           : HashTagDataSource!
    private var hashTagSnapShot             : HashTagSnapShot!
    private var userSelected                : UserResponseDto?
    
    /* OVERRIDE */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: HashTagSearchViewController.TimenoteListCell, bundle: nil), forCellReuseIdentifier: HashTagSearchViewController.TimenoteListCell)
        self.configureHashTagDataSource()
        TimenoteManager.shared.timenoteSearchPublisher.assign(to: \.timenotesSearched, on: self).store(in: &self.cancellableBag)
        SearchViewController.searchBarPublisher.assign(to: \.searchBarText, on: self).store(in: &self.cancellableBag)
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let naviguationController = segue.destination as? UINavigationController, let timenoteDetailViewController = naviguationController.viewControllers.first as? TimenoteDetailViewController {
            timenoteDetailViewController.timenote = self.timenoteDetailSelected
            timenoteDetailViewController.forceEditing = self.timenotCommentSelected
            self.timenotCommentSelected = false
        }
        if let userListViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? UserListViewController {
            userListViewController.timenoteId = self.timenoteDetailSelected?.id
            self.timenoteDetailSelected = nil
        }
        if let followingListViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? FollowingListViewController {
            followingListViewController.timenoteId = self.timenoteDetailSelected?.id
            self.timenoteDetailSelected = nil
        }
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            profilViewController.user = self.userSelected
            self.userSelected = nil
        }
    }
    
    private func configureHashTagDataSource() {
        self.hashTagDataSource = HashTagDataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, timenote) -> UITableViewCell? in
            let timenoteCell = tableView.dequeueReusableCell(withIdentifier: HashTagSearchViewController.TimenoteListCell) as! TimenoteWithHeaderXibView
            timenoteCell.timenoteDelegate = self
            timenoteCell.configure(timenote: timenote)
            if indexPath.row == self.timenotesSearched.count - 12 {
                TimenoteManager.shared.getByTag(tag: self.searchBarText)
            }
            return timenoteCell
        })
        self.hashTagDataSource.defaultRowAnimation = .fade
    }
    
    private func updateHashTagUI(animated: Bool = true) {
        self.hashTagSnapShot = HashTagSnapShot()
        self.hashTagSnapShot.appendSections([.main])
        self.hashTagSnapShot.appendItems(self.timenotesSearched, toSection: .main)
        self.hashTagDataSource.apply(self.hashTagSnapShot, animatingDifferences: animated)
    }
 
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        SearchViewController.searchResignResponder.send(true)
    }
}

extension HashTagSearchViewController : TimeNoteWithHeaderDelegate {
    func didTapUserIcon(timenote: UserResponseDto?) {
        self.userSelected = timenote
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }
    
    func didTapUserListTimenote(timenote: TimenoteDataDto?) {
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goToUserList", sender: self)
    }
    
    func showTimenoteModalViewController(viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func didDuplicateTimenote(timenote: TimenoteDataDto?) {
        /* Nothing to do here */
    }
    
    func didDeleteTimenote(timenote: TimenoteDataDto?) {
        /* Nothing to do here */
    }
    
    func didRemindTimenote(timenote: TimenoteDataDto?) {
        /* Nothing to do here */
    }
    
    func didReportTimenote(timenote: TimenoteDataDto?) {
        /* Nothing to do here */
    }
    
    func didCommentTimenote(timenote: TimenoteDataDto?) {
        self.timenotCommentSelected = true
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
    }
    
    func didShowMoreTimenote(timenote: TimenoteDataDto?) {
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
    }
    
    func didShareTimenote(timenote: TimenoteDataDto?) {
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goFollowingList", sender: self)
    }
    
    func didShowTaggedPeaple(timenote: TimenoteDataDto?) {
        /* Nothing to do here */
    }
    
    
}
