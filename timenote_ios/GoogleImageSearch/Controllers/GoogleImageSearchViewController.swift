//
//  GoogleImageSearchViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 8/16/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol GoogleImageSearchDelegate {
    func didSelectImages(images: [GoogleAPISearchItem])
}

typealias GoogleImageDataSource = UICollectionViewDiffableDataSource<Section, GoogleAPISearchItem>
typealias GoogleImageSnapShot   = NSDiffableDataSourceSnapshot<Section, GoogleAPISearchItem>

class GoogleImageSearchViewController   : UIViewController {
    
    @IBOutlet weak var imageSearchBar: UISearchBar! { didSet {
        self.imageSearchBar.backgroundImage = UIImage()
        self.imageSearchBar.delegate = self
        self.imageSearchBar.becomeFirstResponder()
    }}
    @IBOutlet weak var collectionViewImages: UICollectionView! { didSet {
        self.collectionViewImages.delegate = self
        self.collectionViewImages.loadControl = UILoadControl(target: self, action: #selector(self.didLoadMoreImages))
        self.collectionViewImages.allowsMultipleSelection = true
        self.collectionViewImages.allowsSelection = true
    }}
    
    public  var delegate                    :   GoogleImageSearchDelegate?
    private var currentGoogleApiResponse    :   GoogleAPISearchItemsResult?
    private var selectedImages              :   [GoogleAPISearchItem]       = []
    private var savedTextString             :   String?                     = nil
    
    private var googleImageDataSource : GoogleImageDataSource!
    private var googleImageSnapShot : GoogleImageSnapShot!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
    }
    
    @IBAction func validateIsTapped(_ sender: UIButton) {
        self.delegate?.didSelectImages(images: self.selectedImages)
        self.navigationController?.popViewController(animated: true) 
    }
    
    private func configureDataSource() {
        self.googleImageDataSource = GoogleImageDataSource(collectionView: self.collectionViewImages, cellProvider: { (collectionView, indexPath, googleItem) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoogleImageCell", for: indexPath) as! GoogleImageCell
            cell.configure(googleImage: googleItem, isSelected: self.selectedImages.contains(where: {$0.image.thumbnailLink == googleItem.image.thumbnailLink}))
            if indexPath.row == (self.currentGoogleApiResponse?.items.count ?? 0) - 10 {
                self.didLoadMoreImages()
            }
            return cell
        })
    }
    
    private func updateUI(animated: Bool = true) {
        guard let response = self.currentGoogleApiResponse?.items else { return }
        self.googleImageSnapShot = GoogleImageSnapShot()
        self.googleImageSnapShot.appendSections([.main])
        self.googleImageSnapShot.appendItems(response, toSection: .main)
        self.googleImageDataSource.apply(self.googleImageSnapShot, animatingDifferences: animated)
        self.collectionViewImages.collectionViewLayout.invalidateLayout()
    }

    @objc func didLoadMoreImages() {
        guard let string = self.savedTextString, !string.isEmpty else { return }
        GoogleSearchImageEngineManager.shared.searchImageWithText(text: self.imageSearchBar.text, paginationIndex: self.currentGoogleApiResponse?.nextPage?.startIndex ?? 0) { (result) in
            self.collectionViewImages.loadControl?.endLoading()
            switch result {
            case .failure(_):
                break;
            case .success(let googleSearchResponse):
                var newItems = self.currentGoogleApiResponse?.items ?? []
                newItems.append(contentsOf: googleSearchResponse.items)
                newItems.removeDuplicates()
                self.currentGoogleApiResponse = GoogleAPISearchItemsResult(items: newItems,  nextPage: googleSearchResponse.nextPage)
                self.updateUI()
            }
        }
    }
    
}

extension GoogleImageSearchViewController   : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImages.append(self.currentGoogleApiResponse!.items[indexPath.row])
        self.collectionViewImages.selectItem(at: indexPath, animated: true, scrollPosition: [])
        self.googleImageSnapShot.reloadItems([self.currentGoogleApiResponse!.items[indexPath.row]])
        self.googleImageDataSource.apply(self.googleImageSnapShot)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.selectedImages.removeAll(where: {$0.image.thumbnailLink == self.currentGoogleApiResponse?.items[indexPath.row].image.thumbnailLink})
        self.collectionViewImages.deselectItem(at: indexPath, animated: true)
        self.googleImageSnapShot.reloadItems([self.currentGoogleApiResponse!.items[indexPath.row]])
        self.googleImageDataSource.apply(self.googleImageSnapShot)
    }
    
    /* LOADER CONTROL */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.currentGoogleApiResponse?.items.isEmpty == false else { return }
        self.collectionViewImages.loadControl?.updateUI(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard self.currentGoogleApiResponse?.items.isEmpty == false else { return }
        self.collectionViewImages.loadControl?.updateUI(scrollView: scrollView, true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard self.currentGoogleApiResponse?.items.isEmpty == false else { return }
        self.collectionViewImages.loadControl?.updateUI(scrollView: scrollView, false, true)
    }
    
}

extension GoogleImageSearchViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchBar.text?.isEmpty == false else { return }
        self.savedTextString = searchBar.text
        GoogleSearchImageEngineManager.shared.searchImageWithText(text: searchBar.text, paginationIndex: 0) { (result) in
            switch result {
            case .failure(_):
                break;
            case .success(let googleSearchResponse):
                self.currentGoogleApiResponse = googleSearchResponse
                self.updateUI()
                searchBar.endEditing(true)
            }
        }
    }
}
