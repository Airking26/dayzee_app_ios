//
//  FuturFeedViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 16/11/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine


typealias TimenotePostitDataSource  = UICollectionViewDiffableDataSource<Section, TimenoteDataDto>
typealias TimenotePostitSnapShot    = NSDiffableDataSourceSnapshot<Section, TimenoteDataDto>


typealias TimenoteFutureDataSource  = UITableViewDiffableDataSource<Section, TimenoteDataDto>
typealias TimenoteFutureSnapShot    = NSDiffableDataSourceSnapshot<Section, TimenoteDataDto>

class FuturFeedViewController : UITableViewController {
    
    @IBOutlet weak var labelNothingToShow: UILabel!
    @IBOutlet weak var postedCollectionView: UICollectionView! { didSet {
        self.postedCollectionView.register(UINib(nibName: FuturFeedViewController.PostedCellName, bundle: nil), forCellWithReuseIdentifier: FuturFeedViewController.PostedCellName)
        self.postedCollectionView.delegate = self
    }}

    static let PostedCellName               : String                    = "TimenoteNewPostXibView"
    static let ListCellName                 : String                    = "TimenoteWithHeaderXibView"

    private var timenotesFuture             : [TimenoteDataDto]         = [] { didSet {
        self.updateFutureUI()
    }}
    private var timenotesFutureDataSource   : TimenoteFutureDataSource!
    private var timenotesFutureSnapShot     : TimenoteFutureSnapShot!
    private var timenotesPostit             : [TimenoteDataDto]         = [] { didSet {
        self.updatePostitUI()
    }}
    private var timenotePostitDataSource    : TimenotePostitDataSource!
    private var timenotePostitSnapShot      : TimenotePostitSnapShot!
    private var cancellableBag              = Set<AnyCancellable>()
    private var timenoteDetailSelected      : TimenoteDataDto?          = nil
    private var timenotCommentSelected      : Bool                      = false
    private var userSelected                : UserResponseDto?          = nil
    private var isFirstUpdate               : Bool                      = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureFutureDataSource()
        self.configurePostitDataSource()
        self.configureRefresh()
        TimenoteManager.shared.updateTimenoteHomePublicher.sink(receiveValue: {if $0 { self.updateItems()}}).store(in: &self.cancellableBag)
        TimenoteManager.shared.timenoteUpcomingPublisher.assign(to: \.self.timenotesFuture, on: self).store(in: &self.cancellableBag)
        TimenoteManager.shared.timenoteRecentPublisher.assign(to: \.self.timenotesPostit, on: self).store(in: &self.cancellableBag)
        self.getTimenotes()
    }
    
    private func updateItems() {
        self.getTimenotes()
        self.tableView.refreshControl?.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    private func configureRefresh() {
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(self.refreshData), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControll
    }
    
    private func getTimenotes() {
        DispatchQueue.global().async {
            TimenoteManager.shared.getUpcoming(refresh: true)
            TimenoteManager.shared.getRecent(refresh: true)
        }
    }
    
    @objc public func refreshData() {
        self.getTimenotes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let naviguationController = segue.destination as? UINavigationController, let timenoteDetailViewController = naviguationController.viewControllers.first as? TimenoteDetailViewController {
            timenoteDetailViewController.timenote = self.timenoteDetailSelected
            timenoteDetailViewController.forceEditing = self.timenotCommentSelected
            self.timenotCommentSelected = false
            self.timenoteDetailSelected = nil
        }
        if let userListViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? UserListViewController {
            userListViewController.timenoteId = self.timenoteDetailSelected?.id
            self.timenoteDetailSelected = nil
        }
        if let followingListViewController =  (segue.destination as? UINavigationController)?.viewControllers.first as? FollowingListViewController {
            followingListViewController.timenoteId = self.timenoteDetailSelected?.id
            self.timenoteDetailSelected = nil
        }
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            profilViewController.user = self.userSelected
            self.userSelected = nil
        }
    }
    
    private func configurePostitDataSource() {
        self.timenotePostitDataSource = TimenotePostitDataSource(collectionView: self.postedCollectionView, cellProvider: { (collectionView, indexPath, timenote) -> UICollectionViewCell? in
            let timenotePostCell = collectionView.dequeueReusableCell(withReuseIdentifier: FuturFeedViewController.PostedCellName, for: indexPath) as! TimenoteNewPostXibView
            timenotePostCell.configure(timenote: timenote)
            if indexPath.row == self.timenotesPostit.count - 12 {
                DispatchQueue.main.async {
                    TimenoteManager.shared.getRecent(refresh: false)
                }
            }
            return timenotePostCell
        })
    }

    
    private func updatePostitUI(animated: Bool = false) {
        self.timenotePostitSnapShot = TimenotePostitSnapShot()
        self.timenotePostitSnapShot.appendSections([.main])
        self.timenotePostitSnapShot.appendItems(self.timenotesPostit, toSection: .main)
        DispatchQueue.main.async {
            self.timenotePostitDataSource.apply(self.timenotePostitSnapShot, animatingDifferences: animated || self.refreshControl?.isRefreshing ?? false)
            guard !self.isFirstUpdate else { return
                self.isFirstUpdate = false
            }
            self.labelNothingToShow.isHidden = self.timenotesPostit.count != 0
        }
    }
    
    private func configureTableView() {
        self.tableView.estimatedRowHeight = 420
        self.tableView.isSkeletonable = true
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: FuturFeedViewController.ListCellName, bundle: nil), forCellReuseIdentifier: FuturFeedViewController.ListCellName)
    }
    
    
    private func configureFutureDataSource() {
        self.timenotesFutureDataSource = TimenoteFutureDataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, timenote) -> UITableViewCell? in
            let timenoteCell = tableView.dequeueReusableCell(withIdentifier: FuturFeedViewController.ListCellName) as! TimenoteWithHeaderXibView
            timenoteCell.timenoteDelegate = self
            timenoteCell.configure(timenote: timenote)
            if indexPath.row == self.timenotesFuture.count - 1 {
                DispatchQueue.main.async {
                    TimenoteManager.shared.getUpcoming(refresh: false)
                }
            }
            return timenoteCell
        })
        self.timenotesFutureDataSource.defaultRowAnimation = .fade
    }
    
    private func updateFutureUI(animated: Bool = false) {
        self.timenotesFutureSnapShot = TimenoteFutureSnapShot()
        self.timenotesFutureSnapShot.appendSections([.main])
        self.timenotesFutureSnapShot.appendItems(self.timenotesFuture, toSection: .main)
        DispatchQueue.main.async {
            self.timenotesFutureDataSource.apply(self.timenotesFutureSnapShot, animatingDifferences: animated || self.refreshControl?.isRefreshing ?? false)
            self.tableView.refreshControl?.endRefreshing()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension FuturFeedViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 135, height: 130)
    }
            
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.timenoteDetailSelected = self.timenotesPostit[indexPath.row]
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
    }
    
}

extension FuturFeedViewController : TimeNoteWithHeaderDelegate {
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
            TimenoteManager.shared.getUpcoming(refresh: true)
            TimenoteManager.shared.getRecent(refresh: true)
            TimenoteManager.shared.getPast(refresh: true)
        }
    }
    
}

