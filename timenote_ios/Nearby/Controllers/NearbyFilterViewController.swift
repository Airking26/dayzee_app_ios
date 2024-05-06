//
//  NearbyFilterViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 27/10/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces

protocol NearbyFilterDelegate {
    func didUpdateFilter(nearbyFilterOption: FilterNearbyDto?)
}

class NearbyFilterViewController : UIViewController {
    
    @IBOutlet weak var nearbyDataPicker: DataPickerTextField! { didSet {
        var categories = [""]
        categories.append(contentsOf: CategorieManager.shared.postCategories.map({$0.subcategory}).flatMap({$0}) )
        self.nearbyDataPicker.setPickerData(categories, self.nearbyDataPicker.debugDescription)
    }}
    @IBOutlet weak var shareWithDataPicker: DataPickerTextField! { didSet {
        self.shareWithDataPicker.setPickerData(FilterOptionDto.allValues, self.shareWithDataPicker.debugDescription)
    }}
    @IBOutlet weak var payedDataPicker: DataPickerTextField! { didSet {
        self.payedDataPicker.setPickerData(Locale.current.isFrench ? ["Gratuit", "Payant"] : ["Free", "Paying"], self.payedDataPicker.debugDescription)
    }}
    @IBOutlet weak var dateDataPicker: DatePickerTextField! { didSet {
        self.dateDataPicker.datePickerDelegate = self
        self.dateDataPicker.isTimeActivated = false
    }}
    @IBOutlet weak var adresseDataPicker: UITextField! { didSet {
        self.adresseDataPicker.addTarget(self, action: #selector(self.openPlaces), for: .editingDidBegin)
    }}
    @IBOutlet weak var distanceSlider: UISlider! { didSet {
        self.distanceSlider.addTarget(self, action: #selector(self.updateDistance), for: .valueChanged)
    }}
    @IBOutlet weak var distanceLabel: UILabel!
    
    private var userLocation    : UserLocationDto?  = nil { didSet {
        self.adresseDataPicker.text = userLocation?.address.address
    }}
    private var filterNearbyDto : FilterNearbyDto?  = TimenoteManager.shared.timenoteNearbyOptionPublisher.value

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func saveIsTapped(_ sender: UIButton) {
        let categorieSearched = CategorieManager.shared.getCategorieOfSubCategorie(subCategorie: self.nearbyDataPicker.text)
        let categorie = self.nearbyDataPicker.text?.isEmpty == true ? [] : categorieSearched != nil ? [categorieSearched!] : []
        let price = self.payedDataPicker.text == (Locale.current.isFrench ? "Gratuit" : "Free") ? TimenotePriceDto(value: 0, currency: "") : TimenotePriceDto(value: 1, currency: "")
        if let location = self.userLocation {
            let filterOption = FilterNearbyDto(location: location, maxDistance: Int(self.distanceSlider.value), categories: categorie, date: self.dateDataPicker.datePickerView.date.iso8601withFractionalSeconds, price: price, type: FilterOptionDto.fromString(string: self.shareWithDataPicker.text) ?? FilterOptionDto.all)
            TimenoteManager.shared.timenoteNearbyOptionPublisher.send(filterOption)
            self.dismiss(animated: true, completion: nil)
        } else {
            GoogleLocationManager.shared.getUserTimenoteLocation { (userLocation) in
                guard let userLocation = userLocation else { return }
                let filterOption = FilterNearbyDto(location: userLocation, maxDistance: Int(self.distanceSlider.value), categories: categorie, date: self.dateDataPicker.datePickerView.date.iso8601withFractionalSeconds, price: price, type: FilterOptionDto.fromString(string: self.shareWithDataPicker.text) ?? FilterOptionDto.all)
                TimenoteManager.shared.timenoteNearbyOptionPublisher.send(filterOption)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func resetIsTapped(_ sender: UIButton) {
        GoogleLocationManager.shared.getUserTimenoteLocation { (userLocation) in
            guard let userLocation = userLocation else { return }
            let filterOption = FilterNearbyDto(location: userLocation , maxDistance: NearbyViewController.MinDistance, categories: [], date: Date().iso8601withFractionalSeconds, price: TimenotePriceDto(value: 0, currency: ""), type: FilterOptionDto.all)
            self.filterNearbyDto = filterOption
            DispatchQueue.main.async {
                self.configureView()
            }
        }
    }

    @objc public func updateDistance() {
        DispatchQueue.main.async {
            self.distanceLabel.text = "\(Int(self.distanceSlider.value)) km"
        }
    }
    
    private func configureView() {
        self.dateDataPicker.datePickerView.date = Date()
        guard let filterNearbyDto = self.filterNearbyDto else { return }
        self.nearbyDataPicker.text = filterNearbyDto.categories.first?.subcategory
        self.shareWithDataPicker.text = filterNearbyDto.type.string
        self.payedDataPicker.text = filterNearbyDto.price.value == 0 ? Locale.current.isFrench ? "Gratuit" : "Free" : Locale.current.isFrench ? "Payant" : "Paying"
        self.dateDataPicker.text = filterNearbyDto.date.iso8601withFractionalSeconds?.toString()
        self.dateDataPicker.datePickerView.date =  filterNearbyDto.date.iso8601withFractionalSeconds ?? Date()
        self.userLocation = filterNearbyDto.location
        self.adresseDataPicker.text = filterNearbyDto.location.address.address
        self.distanceSlider.value = Float(filterNearbyDto.maxDistance)
        self.distanceLabel.text = "\(filterNearbyDto.maxDistance) km"
    }
    
    @objc func openPlaces() {
        GoogleLocationManager.shared.presentGoogleAutoComplete(self)
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension NearbyFilterViewController : GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        GoogleLocationManager.shared.getTimenoteLocation(place: place) { (userLocation) in
            self.userLocation = userLocation
            viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension NearbyFilterViewController : DatePickerTextFieldDelegate {
    func didUpdateSelectedDate(_ date: Date, _ dateToString: String, textField: UITextField?) {
        self.dateDataPicker.text = dateToString
    }
}
