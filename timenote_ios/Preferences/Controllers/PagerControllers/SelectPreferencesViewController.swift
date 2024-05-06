//
//  SelectPreferencesViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 22/03/2021.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

struct UserRatingCategorieDto : Hashable {
    let subCategorie    : String
    var rating          : Double
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(subCategorie)
    }
    
    public static func == (lhs: UserRatingCategorieDto, rhs: UserRatingCategorieDto) -> Bool {
        return lhs.subCategorie == rhs.subCategorie
    }
}

struct UserPreferenceDto : Hashable {
    var subCategorie    : [UserRatingCategorieDto]
    let name            : String
    var enabled         : Bool = true
}

typealias UserPreferencesDataSource = UICollectionViewDiffableDataSource<Section, UserPreferenceDto>
typealias UserPreferencesSnapShot   = NSDiffableDataSourceSnapshot<Section, UserPreferenceDto>

class SelectPreferencesViewController : UIViewController {
    
    @IBOutlet weak var nextIsTapped: UIButton!
    @IBOutlet weak var collectionViewPreferences: UICollectionView! { didSet {
        self.collectionViewPreferences.delegate = self
        self.collectionViewPreferences.allowsMultipleSelection = true
        self.collectionViewPreferences.allowsSelection = true
    }}
    
    private var preferenceListDataSource    : UserPreferencesDataSource!
    private var preferenceListSnapShot      : UserPreferencesSnapShot!
    private var preferences                 : [PreferenceDto]               = [] { didSet {
        self.userPreferences.removeAll()
        self.preferences.forEach({ (preference) in
            if let index = self.userPreferences.firstIndex(where: {$0.name == preference.category.category}) {
                self.userPreferences[index].subCategorie.append(UserRatingCategorieDto(subCategorie: preference.category.subcategory, rating: preference.rating))
            } else {
                self.userPreferences.append(UserPreferenceDto(subCategorie: [UserRatingCategorieDto(subCategorie: preference.category.subcategory, rating: preference.rating)], name: preference.category.category))
            }
        })
        CategorieManager.shared.categories?.forEach({ (categorie) in
            if (self.userPreferences.firstIndex(where: {$0.name.lowercased() == categorie.category.lowercased()}) == nil) {
                self.userPreferences.append(UserPreferenceDto(subCategorie: categorie.subcategory.map({UserRatingCategorieDto(subCategorie: $0.description, rating: 0)}), name: categorie.category, enabled: false))
            }
        })
        self.updateUI()
    }}
    private var userPreferences             : [UserPreferenceDto] = []
    private var cancellableBag              = Set<AnyCancellable>()
    
    public  var controlDelegate             : PagerDeleguate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            UserManager.shared.getUserPrefs()
            CategorieManager.shared.getCategories()
        }
        self.configureDataSource()
        UserManager.shared.userPreferencePublisher.assign(to: \.preferences, on: self).store(in: &self.cancellableBag)
    }
    
    @IBAction func nextIsTapped(_ sender: UIButton) {
        PreferencePagerController.passthrougtDataPublisher.value = self.userPreferences
        self.controlDelegate?.swipeToNext()
    }
    
    private func configureDataSource() {
        self.preferenceListDataSource = UserPreferencesDataSource(collectionView: self.collectionViewPreferences, cellProvider: { (collectionView, indexPath, preference) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPreferenceCell", for: indexPath) as? UserPreferenceCell
            cell?.configure(preference: preference)
            return cell
        })
    }
    
    private func updateUI() {
        self.preferenceListSnapShot = UserPreferencesSnapShot()
        self.preferenceListSnapShot.appendSections([.main])
        self.preferenceListSnapShot.appendItems(self.userPreferences)
        DispatchQueue.main.async {
            self.preferenceListDataSource.apply(self.preferenceListSnapShot, animatingDifferences: true)
            self.collectionViewPreferences.reloadData()
        }
    }
}

extension SelectPreferencesViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.view.layoutSubviews()
        let width = (self.collectionViewPreferences.bounds.width - 30) / 3.05
        let height = width / 0.7
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.userPreferences[indexPath.row].enabled = !self.userPreferences[indexPath.row].enabled
        self.updateUI()
    }
    
}
