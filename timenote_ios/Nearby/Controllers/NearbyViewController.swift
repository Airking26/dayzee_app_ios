//
//  NearbyVC.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Combine

typealias NearbyDataSource  = UITableViewDiffableDataSource<Section, TimenoteDataDto>
typealias NearbySnapShot    = NSDiffableDataSourceSnapshot<Section, TimenoteDataDto>

protocol FilterDelegate {
    func didUpdate(categorie: CategorieDto?, filter: FilterOptionDto, price: TimenotePriceDto, distance: Int, date: Date?, place: GMSPlace?)
}

class NearbyViewController: UIViewController {

    // OUTLET
    @IBOutlet weak var timenoteTableView: UITableView! {
        didSet {
            self.timenoteTableView.estimatedRowHeight = 400
            self.timenoteTableView.rowHeight = UITableView.automaticDimension
            self.timenoteTableView.delegate = self
            self.timenoteTableView.register(UINib(nibName: NearbyViewController.ListCellName, bundle: nil), forCellReuseIdentifier: NearbyViewController.ListCellName)
        }
    }
    @IBOutlet weak var mapView: UIView! {
        didSet {
            self.googleMapView = GMSMapView.map(withFrame: self.mapView.frame, camera: GMSCameraPosition())
            self.googleMapView.isMyLocationEnabled = true
            self.googleMapView.delegate = self
            self.mapView.addSubview(self.googleMapView)
        }
    }
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changeFiltersLabel: UILabel!
    @IBOutlet weak var dateTextField: DatePickerTextField! { didSet {
        self.dateTextField.isTimeActivated = false
        self.dateTextField.datePickerDelegate = self
    }}
    
    // STATIC
    static let ListCellName     : String    = "TimenoteWithHeaderXibView"
    static let MinDistance      : Int       = 10
    static let MaxDistance      : Int       = 250
    
    // VARIABLES

    private var timenoteDetailSelected      : TimenoteDataDto?  = nil
    private var timenotCommentSelected      : Bool              = false
    private var googleMapView               : GMSMapView!
    private var timenotes                   : [TimenoteDataDto] = [] { didSet {
        self.timenoteMarkers.forEach({$0.map = nil})
        self.timenoteMarkers.removeAll()
        self.updateUI()
    }}
    private var nearbyDataSource            : NearbyDataSource!
    private var nearbySnapShot              : NearbySnapShot!
    private var cancellableBag              = Set<AnyCancellable>()
    private var userPosition                : CLLocationCoordinate2D?
    private var userMarker                  = GMSMarker()
    private var timenoteMarkers             = [GMSMarker]()
    private var userSelected                : UserResponseDto?
    private var filterOptions               : FilterNearbyDto? { didSet {
        self.configureView()
        TimenoteManager.shared.getNearbyTimenotes(refresh: true)
        self.timenoteTableView.setContentOffset(.zero, animated: true)
    }}

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
        TimenoteManager.shared.getNearbyTimenotes(refresh: true)
        TimenoteManager.shared.timenoteNearbyOptionPublisher.assign(to: \.self.filterOptions, on: self).store(in: &self.cancellableBag)
        TimenoteManager.shared.timenoteNearbyPublisher.assign(to: \.self.timenotes, on: self).store(in: &self.cancellableBag)
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
        if let followingListViewController =  (segue.destination as? UINavigationController)?.viewControllers.first as? FollowingListViewController {
            followingListViewController.timenoteId = self.timenoteDetailSelected?.id
            self.timenoteDetailSelected = nil
        }
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            profilViewController.user = self.userSelected
            self.userSelected = nil
        }
    }
    
    @IBAction func filterIsTapped(_ sender: UIButton) {
        guard !UserManager.shared.isUserWithNoAccount else {
            self.showNoAccountAlert()
            return
        }
        self.performSegue(withIdentifier: "goToFilterOptions", sender: self)
    }
    
    private func configureView() {
        guard let nearbyOption = self.filterOptions else { return }
        let date = nearbyOption.date.iso8601withFractionalSeconds ?? Date()
        var day = date.getDayString()
        let _ = day.popLast()
        DispatchQueue.main.async {
            self.dateTextField.text = "\(day), \(date.getDay()) \(date.getMonthString()) \(date.getYear())"
        }
        guard let latitude = self.filterOptions?.location.latitude, let longitude = self.filterOptions?.location.longitude else {
            if let myPosition = self.googleMapView.myLocation?.coordinate {
                DispatchQueue.main.async {
                    self.googleMapView.animate(with: GMSCameraUpdate.setCamera(GMSCameraPosition.init(target: myPosition, zoom: 10)))
                    self.userMarker.map = nil
                }
            } else {
                GoogleLocationManager.shared.getLocationWithUpdate { (place, adresse, errors) in
                    guard let place = place else { return }
                    DispatchQueue.main.async {
                        self.googleMapView.animate(with: GMSCameraUpdate.setCamera(GMSCameraPosition.init(target: place.coordinate, zoom: 10)))
                    }
                }
            }
            return
        }
        GoogleLocationManager.shared.getLastSelectedPlace { (place, adresse, error) in
            guard let place = place else { return }
            let destinationPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            guard destinationPosition.latitude != place.coordinate.latitude && destinationPosition.longitude != place.coordinate.longitude else {
                DispatchQueue.main.async {
                    self.googleMapView.animate(with: GMSCameraUpdate.setCamera(GMSCameraPosition.init(target: place.coordinate, zoom: 10)))
                    self.userMarker.map = nil
                }
                return
            }
            let bounds = GMSCoordinateBounds(coordinate: place.coordinate, coordinate: destinationPosition)
            let camera: GMSCameraUpdate = GMSCameraUpdate.fit(bounds, with: .init(top: 100, left: 60, bottom: 100, right: 60))
            DispatchQueue.main.async {
                self.userMarker.map = self.googleMapView
                self.userMarker.position = destinationPosition
                self.googleMapView.animate(with: camera)
            }
        }
    }
    
    private func configureDataSource() {
        self.nearbyDataSource = NearbyDataSource(tableView: self.timenoteTableView, cellProvider: { (tableView, indexPath, timenote) -> UITableViewCell? in
            let timenoteCell = tableView.dequeueReusableCell(withIdentifier: NearbyViewController.ListCellName) as! TimenoteWithHeaderXibView
            timenoteCell.timenoteDelegate = self
            timenoteCell.configure(timenote: timenote)
            if indexPath.row == self.timenotes.count - 3 {
                TimenoteManager.shared.getNearbyTimenotes(refresh: false)
            }
            return timenoteCell
        })
        self.nearbyDataSource.defaultRowAnimation = .fade
    }
    
    private func updateUI() {
        self.nearbySnapShot = NearbySnapShot()
        self.nearbySnapShot.appendSections([.main])
        self.nearbySnapShot.appendItems(self.timenotes)
        self.nearbyDataSource.apply(self.nearbySnapShot, animatingDifferences: true)
        self.changeFiltersLabel.isHidden = !(self.timenotes.count == 0)
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showNoAccountAlert() {
        let alertController = UIAlertController(title: Locale.current.isFrench ? "Vous n'avez pas de compte..." : "You are not logged", message: Locale.current.isFrench ? "Veuillez vous authentifier pour effectuer cette action." : "Please signin to make this action", preferredStyle: .alert)
        let connectAction = UIAlertAction(title: Locale.current.isFrench ? "Je me connecte" : "Sign-in", style: .default) { (action) in
            UserManager.shared.isUserWithNoAccount = false
            self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.navigationController?.popToRootViewController(animated: true)
        }
        let retourAction = UIAlertAction(title: Locale.current.isFrench ? "Retour" : "Back", style: .cancel) { (action) in
        }
        retourAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(connectAction)
        alertController.addAction(retourAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension NearbyViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension NearbyViewController: TimeNoteWithHeaderDelegate {
    func didTapUserIcon(timenote: UserResponseDto?) {
        guard !UserManager.shared.isUserWithNoAccount else {
            self.showNoAccountAlert()
            return
        }
        self.userSelected = timenote
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }
    
    func didTapUserListTimenote(timenote: TimenoteDataDto?) {
        guard !UserManager.shared.isUserWithNoAccount else {
            self.showNoAccountAlert()
            return
        }
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
        guard !UserManager.shared.isUserWithNoAccount else {
            self.showNoAccountAlert()
            return
        }
        self.timenotCommentSelected = true
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
    }
    
    func didShowMoreTimenote(timenote: TimenoteDataDto?) {
        guard !UserManager.shared.isUserWithNoAccount else {
            self.showNoAccountAlert()
            return
        }
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
    }
    
    func didShareTimenote(timenote: TimenoteDataDto?) {
        guard !UserManager.shared.isUserWithNoAccount else {
            self.showNoAccountAlert()
            return
        }
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goFollowingList", sender: self)
    }
    
    func didShowTaggedPeaple(timenote: TimenoteDataDto?) {
        /* Nothing to do here */
    }
    
    func reloadData() {
        self.updateUI()
    }
        
}

extension NearbyViewController : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        // MAKE TIMENOTE UPDATE
    }
    
}

extension NearbyViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = self.mapViewHeight.constant - scrollView.contentOffset.y
        let height = min(max(y, 220), 350)
        self.mapViewHeight.constant = height
        self.view.layoutIfNeeded()
        if height != 220 {
            scrollView.contentOffset.y = 0
        }
    }

}

extension NearbyViewController : DatePickerTextFieldDelegate {
    
    func didUpdateSelectedDate(_ date: Date, _ dateToString: String, textField: UITextField?) {
        guard !UserManager.shared.isUserWithNoAccount else {
            self.showNoAccountAlert()
            return
        }
        self.filterOptions?.date = date.iso8601withFractionalSeconds
        TimenoteManager.shared.timenoteNearbyOptionPublisher.value = self.filterOptions
        var day = date.getDayString()
        let _ = day.popLast()
        DispatchQueue.main.async {
            self.dateTextField.text = "\(day), \(date.getDay()) \(date.getMonthString()) \(date.getYear())"
        }
    }
    
}
