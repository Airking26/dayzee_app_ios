//
//  ExploreViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/26/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

struct ExploreCategorie : Hashable {
    let category            : String
    let subcategory         : [String]
    var collapsed           : Bool  = false
}

typealias ExploreDataSource  = UITableViewDiffableDataSource<String, String>
typealias ExploreSnapShot    = NSDiffableDataSourceSnapshot<String, String>

class ExploreViewController : UITableViewController {
    
    static  let HeaderSection   : String    = "ExploreHeaderXibView"
    
    private var exploreCategories   : [ExploreCategorie]    = [] { didSet {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
        }
    }}
    private var cancellableBag      : Set<AnyCancellable>   = Set<AnyCancellable>()
    private var exploreDataSource   : ExploreDataSource!
    private var exploreSnapShot     : ExploreSnapShot!
    private var selectedCategorie   : IndexPath?            = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: ExploreViewController.HeaderSection, bundle: nil), forHeaderFooterViewReuseIdentifier: ExploreViewController.HeaderSection)
        self.configureDataSource()
        CategorieManager.shared.categoriesPublisher.map({$0.map({ExploreCategorie(category: $0.category, subcategory: $0.subcategory)})}).assign(to: \.exploreCategories, on: self).store(in: &self.cancellableBag)
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global().async {
            CategorieManager.shared.getCategories()
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userListViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? UserListViewController {
            if let indexPath = self.selectedCategorie {
                userListViewController.categorie = CategorieDto(category: self.exploreCategories[indexPath.section].category, subcategory: self.exploreCategories[indexPath.section].subcategory[indexPath.row])
            }
        }
    }

    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    private func configureDataSource() {
        self.exploreDataSource = ExploreDataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, explore) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTilteCellController") as? ExploreTilteCellController else { return UITableViewCell() }
            cell.configure(categorie: self.exploreCategories[indexPath.section], subcategorie: indexPath.row, showSpacer: indexPath.row == 0)
            return cell
        })
        self.exploreDataSource.defaultRowAnimation = .fade
    }
    
    private func updateUI() {
        self.exploreSnapShot = ExploreSnapShot()
        self.exploreSnapShot.appendSections(self.exploreCategories.map({$0.category}))
        self.exploreCategories.forEach({self.exploreSnapShot.appendItems($0.collapsed ? $0.subcategory : [], toSection: $0.category)})
        self.exploreDataSource.apply(self.exploreSnapShot, animatingDifferences: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExploreViewController.HeaderSection) as! ExploreHeaderXibView
        headerView.configure(delegate: self, section: section, categorie: self.exploreCategories[section], hasBackgroundImage: true)
        headerView.backgroundImageView.borderWidth = 1
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.exploreCategories[indexPath.section].collapsed ? (indexPath.row == 0 ? 55 : 35) : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        65
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCategorie = indexPath
        self.performSegue(withIdentifier: "goToSectionFollowers", sender: self)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        SearchViewController.searchResignResponder.send(true)
    }
}

extension ExploreViewController : CollapseSectionDelegate {
    
    func didCollapse(section: Int?) {
        guard let section = section else { return }
        self.exploreCategories[section].collapsed = !self.exploreCategories[section].collapsed
        self.updateUI()
    }
    
}
