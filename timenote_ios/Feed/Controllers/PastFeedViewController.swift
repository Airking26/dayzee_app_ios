//
//  PastFeedViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 16/11/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

typealias TimenotePastDataSource  = UITableViewDiffableDataSource<Section, TimenoteDataDto>
typealias TimenotePastSnapShot    = NSDiffableDataSourceSnapshot<Section, TimenoteDataDto>

class PastFeedViewController : UITableViewController {
    
    static let ListCellName                 : String                    = "TimenoteWithHeaderXibView"

    private var timenotesPast               : [TimenoteDataDto]         = [] { didSet {
        DispatchQueue.main.async { [weak self] in
            self?.updatePastUI()
        }
    }}
    private var timenotesPastDataSource     : TimenoteFutureDataSource!
    private var timenotesPastSnapShot       : TimenoteFutureSnapShot!
    private var cancellableBag              = Set<AnyCancellable>()
    private var timenoteDetailSelected      : TimenoteDataDto?          = nil
    private var timenotCommentSelected      : Bool                      = false
    private var userSelected                : UserResponseDto?          = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureRefresh()
        self.configureTableView()
        self.configurePastDataSource()
        TimenoteManager.shared.updateTimenoteHomePublicher.sink(receiveValue: {if $0 { self.updateItems()}}).store(in: &self.cancellableBag)
        self.getPastTimenotes()
        TimenoteManager.shared.timenotePastPublisher.assign(to: \.self.timenotesPast, on: self).store(in: &self.cancellableBag)
    }
    
    
    private func updateItems() {
        self.getPastTimenotes()
        self.tableView.refreshControl?.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let naviguationController = segue.destination as? UINavigationController, let timenoteDetailViewController = naviguationController.viewControllers.first as? TimenoteDetailViewController {
            timenoteDetailViewController.timenote = self.timenoteDetailSelected
            timenoteDetailViewController.forceEditing = self.timenotCommentSelected
            self.timenoteDetailSelected = nil
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
    
    private func configureRefresh() {
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(self.refreshData), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControll

    }
    
    @objc public func refreshData() {
        self.getPastTimenotes()
    }
    
    private func configureTableView() {
        self.tableView.estimatedRowHeight = 420
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.isSkeletonable = true
        self.tableView.register(UINib(nibName: PastFeedViewController.ListCellName, bundle: nil), forCellReuseIdentifier: PastFeedViewController.ListCellName)
    }
    
    
    private func configurePastDataSource() {
        self.timenotesPastDataSource = TimenotePastDataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, timenote) -> UITableViewCell? in
            let timenoteCell = tableView.dequeueReusableCell(withIdentifier: PastFeedViewController.ListCellName) as! TimenoteWithHeaderXibView
            timenoteCell.timenoteDelegate = self
            timenoteCell.configure(timenote: timenote)
            if indexPath.row == self.timenotesPast.count - 1 {
                self.getPastTimenotes()
            }
            return timenoteCell
        })
        self.timenotesPastDataSource.defaultRowAnimation = .fade
    }
    
    private func updatePastUI(animated: Bool = false) {
        self.timenotesPastSnapShot = TimenotePastSnapShot()
        self.timenotesPastSnapShot.appendSections([.main])
        self.timenotesPastSnapShot.appendItems(self.timenotesPast, toSection: .main)
        self.timenotesPastDataSource.apply(self.timenotesPastSnapShot, animatingDifferences: animated || self.refreshControl?.isRefreshing ?? false)
        self.tableView.refreshControl?.endRefreshing()
    }
    
    private func getPastTimenotes() {
        DispatchQueue.main.async {
            TimenoteManager.shared.getPast(refresh: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PastFeedViewController : TimeNoteWithHeaderDelegate {
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
    
    func didCommentTimenote(timenote: TimenoteDataDto?) {
        self.timenotCommentSelected = true
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
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
    
    func didShowTaggedPeaple(timenote: TimenoteDataDto?) {
        /* Nothing to do here */
    }
    
    func didShowMoreTimenote(timenote: TimenoteDataDto?) {
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
    }
    
    func didShareTimenote(timenote: TimenoteDataDto?) {
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goFollowingList", sender: self)
    }
    
    func reloadAllData() {
        DispatchQueue.main.async {
            TimenoteManager.shared.getPast(refresh: true)
            TimenoteManager.shared.getUpcoming(refresh: true)
            TimenoteManager.shared.getRecent(refresh: true)
        }
    }
    
}
