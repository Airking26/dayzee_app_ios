//
//  RatePreferencesViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 22/03/2021.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

typealias UserPreferencesListDataSource = UITableViewDiffableDataSource<UserPreferenceDto, UserRatingCategorieDto>
typealias UserPreferencesListSnapShot   = NSDiffableDataSourceSnapshot<UserPreferenceDto, UserRatingCategorieDto>

class RatePreferencesViewController : UIViewController {
    
    @IBOutlet weak var categorieTableView: UITableView! { didSet {
        self.categorieTableView.delegate = self
    }}
    @IBOutlet weak var categorieCollectionView: UICollectionView!
    
    private var preferenceListDataSource        : UserPreferencesDataSource!
    private var preferenceListSnapShot          : UserPreferencesSnapShot!
    private var preferenceListTableDataSource   : UserPreferencesListDataSource!
    private var preferenceListTableSnapShot     : UserPreferencesListSnapShot!

    private var preferences     : [UserPreferenceDto] = [] { didSet {
        self.userPreferences = self.preferences.filter({$0.enabled})
    }}
    private var userPreferences : [UserPreferenceDto] = []

    public  var controlDelegate             : PagerDeleguate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.categorieTableView.register(UINib(nibName: ExploreViewController.HeaderSection, bundle: nil), forHeaderFooterViewReuseIdentifier: ExploreViewController.HeaderSection)
        self.configureDataSource()
        self.configureListDataSource()
        self.initUI()
        self.preferences = PreferencePagerController.passthrougtDataPublisher.value
        self.updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preferences = PreferencePagerController.passthrougtDataPublisher.value
        self.updateUI()
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.controlDelegate?.swipeToViewController(0)
    }
    
    @IBAction func doneIsTapped(_ sender: UIButton) {
        let prefs = PreferencePagerController.passthrougtDataPublisher.value.filter({$0.enabled}).map({ (userPref) -> [PreferenceDto] in
            userPref.subCategorie.map({PreferenceDto.init(category: CategorieDto.init(category: userPref.name, subcategory: $0.subCategorie), rating: $0.rating)})
        }).flatMap({$0})
        UserManager.shared.updateUserPrefs(newPrefs: prefs)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func initUI() {
        self.categorieTableView.layer.cornerRadius =  20
        self.categorieTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func configureDataSource() {
        self.preferenceListDataSource = UserPreferencesDataSource(collectionView: self.categorieCollectionView, cellProvider: { (collectionView, indexPath, preference) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategorieRatingCell", for: indexPath) as? CategorieRatingCell
            cell?.configure(preference: preference)
            cell?.delegate = self
            return cell
        })
    }
    
    private func configureListDataSource() {
        self.preferenceListTableDataSource = UserPreferencesListDataSource(tableView: self.categorieTableView, cellProvider: { (tableView, indexPath, userRating) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceRatingCell") as? PreferenceRatingCell
            else { return UITableViewCell() }
            cell.delegate = self
            cell.configure(rating: userRating)
            return cell
        })
    }
    
    private func updateUI() {
        self.preferenceListSnapShot = UserPreferencesSnapShot()
        self.preferenceListSnapShot.appendSections([.main])
        self.preferenceListSnapShot.appendItems(self.userPreferences)
        DispatchQueue.main.async {
            self.preferenceListDataSource.apply(self.preferenceListSnapShot, animatingDifferences: true)
        }
        
        self.preferenceListTableSnapShot = UserPreferencesListSnapShot()
        self.preferenceListTableSnapShot.appendSections(self.userPreferences)
        self.userPreferences.forEach({self.preferenceListTableSnapShot.appendItems($0.subCategorie, toSection: $0)})
        DispatchQueue.main.async {
            self.preferenceListTableDataSource.apply(self.preferenceListTableSnapShot, animatingDifferences: true)
        }
    }
    
}

extension RatePreferencesViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExploreViewController.HeaderSection) as! ExploreHeaderXibView
        headerView.configure(categorie: self.userPreferences[section])
        headerView.layer.cornerRadius =  20
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var cornerRadius: CGFloat = 0.0
        if indexPath.row == userPreferences[indexPath.section].subCategorie.count - 1 {
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cornerRadius = 10
        }
        cell.layer.cornerRadius = cornerRadius
        cell.addCustomBorder(color: .white, width: 1, corderRadius: cornerRadius, maskedCorners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], isShowBottomBorder: cornerRadius != 0.0)
    }
    
}

extension RatePreferencesViewController: PreferenceRatingCellDelegate, CategorieRatingCellDelegate {
    
    func updatePreference(ratingSubcategorie: UserRatingCategorieDto, with rating: Double) {
        var preferences = self.userPreferences
        guard let categoryIndex = preferences.firstIndex(where: { $0.subCategorie.contains(ratingSubcategorie) }),
              let preferenceIndex = preferences[categoryIndex].subCategorie.firstIndex(where: { $0 == ratingSubcategorie })
        else { return }
        preferences[categoryIndex].subCategorie[preferenceIndex].rating = rating
        var snapshot = UserPreferencesListSnapShot()
        snapshot.appendSections(preferences)
        preferences.forEach { snapshot.appendItems($0.subCategorie, toSection: $0) }
        DispatchQueue.main.async { [weak self] in
            self?.preferenceListTableDataSource.apply(snapshot, animatingDifferences: true)
            self?.preferences = preferences
        }
    }
    
    func preferenceDidDeleted() {
        self.preferences = PreferencePagerController.passthrougtDataPublisher.value
        self.updateUI()
        self.categorieCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                  at: .left,
                                                  animated: true)
    }
    
}
