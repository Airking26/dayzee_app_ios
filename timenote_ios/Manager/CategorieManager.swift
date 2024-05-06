//
//  CategorieManager.swift
//  Timenote
//
//  Created by Aziz Essid on 13/10/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import os.log
import Foundation
import Combine

struct Categories : Codable {
    let category            : String
    var subcategory         : [String]
}

class CategorieManager  {
    
    // Key to find persisted categories
    static let CategoriesKey    : String    = "CategorieManager_CategoriesKey"

    // Shared variable to make this class scope global
    static let shared   : CategorieManager  = CategorieManager()
    // Persited variable to handle offline categories
    @Persisted(key: CategorieManager.CategoriesKey)
    public var categories       : [Categories]?
    public var postCategories   : [Categories] = []
    private(set) var categoriesPublisher    = CurrentValueSubject<[Categories], Never>([])
    
    init() {
        guard let categories = self.categories else { return }
        self.categoriesPublisher.send(categories)
        if let path = Bundle.main.path(forResource: "CategorieLocal", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                self.postCategories = try! JSONDecoder().decode([Categories].self, from: data)
            } catch {
                
            }
        }
        DispatchQueue.global().async { [weak self] in
            self?.getCategories()
        }
    }
    
    public func getCategories() {
        WebService.shared.getCategories { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving categories %{PRIVTE}@", log : OSLog.categorieManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let categories):
                var newCategories : [Categories] = []
                categories.forEach { (categorie) in
                    if let index = newCategories.firstIndex(where: {$0.category == categorie.category}) {
                        newCategories[index].subcategory.append(categorie.subcategory)
                    } else {
                        newCategories.append(Categories(category: categorie.category, subcategory: [categorie.subcategory]))
                    }
                }
                self.categories = newCategories
                self.categoriesPublisher.send(newCategories)
                break;
            }
        }
    }
    
    public func getCategorieWSOfSubCategorie(subCategorie: String?) -> CategorieDto? {
        guard let subCategorie = subCategorie else { return nil }
        var categorieSearched : CategorieDto? = nil
        self.categories?.forEach({ (categorie) in
            if categorie.subcategory.first(where: {$0 == subCategorie}) != nil {
                categorieSearched = CategorieDto(category: categorie.category, subcategory: subCategorie)
            }
        })
        return categorieSearched
    }
    
    public func getCategorieOfSubCategorie(subCategorie: String?) -> CategorieDto? {
        guard let subCategorie = subCategorie else { return nil }
        var categorieSearched : CategorieDto? = nil
        self.postCategories.forEach({ (categorie) in
            if categorie.subcategory.first(where: {$0 == subCategorie}) != nil {
                categorieSearched = CategorieDto(category: categorie.category, subcategory: subCategorie)
            }
        })
        return categorieSearched
    }
    
    public func getUsersCategorie(categorie: CategorieDto, offset: Int, completion: @escaping([UserResponseDto]?) -> Void) {
        WebService.shared.getUsersByCategorie(categorie: categorie, offset: offset == 0 ? 0 : offset / 12) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving user of categorie %{PRIVTE}@", log : OSLog.categorieManager, type : .error, errorDescription.rawValue)
                completion(nil)
                break;
            case .success(let users):
                completion(users)
                break;
            }
        }
    }
    
}
