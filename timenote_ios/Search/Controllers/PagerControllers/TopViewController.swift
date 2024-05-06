//
//  TopViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/26/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

typealias TopDataSource = UITableViewDiffableDataSource<CategorieDto, UserResponseDto>
typealias TopSnapShot   = NSDiffableDataSourceSnapshot<CategorieDto, UserResponseDto>

class TopViewController : UITableViewController {
    
    static let ListCellName     : String    = "FollowerXibView"
    static let HeaderTitle      : String    = "SearchTitleXibView"
    
    private var topsDtos        : [TopDto]  = [] { didSet {
        var newTops : [TopDto] = []
        self.topsDtos.filter({!$0.users.isEmpty}).forEach { (categorie) in
            if let index = newTops.firstIndex(where: {$0.category.subcategory == categorie.category.subcategory}) {
                newTops[index].users.append(contentsOf: categorie.users)
                newTops[index].users.removeDuplicates()
            } else {
                newTops.append(TopDto(category: categorie.category, users: categorie.users))
            }
        }
        self.arrengedTopsDto = newTops
    }}
    private var arrengedTopsDto : [TopDto] = [] { didSet {
        self.updateUI()
    }}
    private var selectedIndexPath   : IndexPath?            = nil
    private var cancellableBag      = Set<AnyCancellable>()
    private var topDataSource       : TopDataSource!
    private var topSnapShot         : TopSnapShot!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            guard let indexPath = self.selectedIndexPath else { return }
            profilViewController.user = self.arrengedTopsDto[indexPath.section].users[indexPath.row]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.configureDataSrouce()
        UserManager.shared.getTops()
        UserManager.shared.topPublisher.assign(to: \.self.topsDtos, on: self).store(in: &self.cancellableBag)
        self.tableView.register(UINib(nibName: TopViewController.ListCellName, bundle: nil), forCellReuseIdentifier: TopViewController.ListCellName)
        self.tableView.register(UINib(nibName: TopViewController.HeaderTitle, bundle: nil), forHeaderFooterViewReuseIdentifier: TopViewController.HeaderTitle)
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global().async {
            UserManager.shared.getTops()
        }
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    private func initUI() {
        self.tableView.cornerRadius = 20
        self.tableView.backgroundColor = .clear
    }
    
    private func configureDataSrouce() {
        self.topDataSource = TopDataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, user) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: TopViewController.ListCellName) as? FollowerXibView
            cell?.configure(follower: user)
            return cell
        })
    }
    
    private func updateUI() {
        var snapShot = TopSnapShot()
        let categories = self.arrengedTopsDto.map({$0.category})
        snapShot.appendSections(categories)
        for category in categories {
            for top in self.arrengedTopsDto {
                if top.category == category {
                    snapShot.appendItems(top.users, toSection: category)
                }
            }
        }
        self.topSnapShot = snapShot
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(applySnapshot),
            object: nil
        )
        perform(#selector(applySnapshot), with: nil, afterDelay: 0.2)
    }
    
    @objc func applySnapshot() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.topDataSource.apply(self.topSnapShot, animatingDifferences: true)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: TopViewController.HeaderTitle)! as? SearchTitleXibView
        view?.initUI(topDto: self.arrengedTopsDto[section])
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        75
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        15
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        SearchViewController.searchResignResponder.send(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var cornerRadius: CGFloat = 0.0
        if indexPath.row == arrengedTopsDto[indexPath.section].users.count - 1 {
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cornerRadius = 20
        }
        cell.layer.cornerRadius = cornerRadius
        cell.addCustomBorder(color: .white, width: 1, corderRadius: cornerRadius, maskedCorners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], isShowBottomBorder: cornerRadius != 0.0)
    }
    
}
