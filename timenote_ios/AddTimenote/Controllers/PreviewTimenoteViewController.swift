//
//  PreviewTimenoteViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 05/11/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import ImageSlideshow

protocol PreviewDelegate {
    func didPost()
}

class PreviewTimenoteViewController : UIViewController {
    
    @IBOutlet weak var adresseLabel: UILabel!
    @IBOutlet weak var timenoteDesciptionLabel: UILabel!
    @IBOutlet weak var timenoteNameLabel: UILabel!
    @IBOutlet weak var timenoteYearLabel: UILabel!
    @IBOutlet weak var timenoteDayLabel: UILabel!
    @IBOutlet weak var timenoteMonthLabel: UILabel!
    @IBOutlet weak var timenoteTimeLabel: UILabel!
    @IBOutlet weak var pagerControll: UIPageControl!
    @IBOutlet weak var timenoteImageView: ImageSlideshow! { didSet {
        self.timenoteImageView.slideshowInterval = 0
        self.timenoteImageView.delegate = self
        self.timenoteImageView.pageIndicator = nil
        self.timenoteImageView.circular = false
        self.timenoteImageView.contentScaleMode = UIViewContentMode.scaleAspectFill
    }}
    
    private var usersIdShare    : [String]          = []
    public  var delegate        : PreviewDelegate?
    public  var timenoteDto     : CreateTimenoteDto! { didSet {
        guard self.isViewLoaded else { return }
        self.setTimenoteInfo()
        self.setTimenoteImages()
    }}
    
    @IBAction func comfirmIsTapped(_ sender: Any) {
        TimenoteManager.shared.addTimenote(timenote: self.timenoteDto) { (success) in
            self.delegate?.didPost()
            UserManager.shared.shareTimenoteWithUsers(timenoteId: success?.id, users: self.usersIdShare)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let followingListViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? FollowingListViewController {
            followingListViewController.isSharing = false
            followingListViewController.delegate = self
            followingListViewController.selectedUsers = self.usersIdShare
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTimenoteInfo()
        self.setTimenoteImages()
    }
    
    private func setTimenoteInfo() {
        self.timenoteNameLabel.text = self.timenoteDto?.title.uppercased()
        let startingDate = self.timenoteDto?.startingAt.iso8601withFractionalSeconds
        self.timenoteYearLabel.text = startingDate?.getYear()
        self.timenoteDayLabel.text = startingDate?.getDay()
        self.timenoteMonthLabel.text = startingDate?.getMonthNameString()
        self.timenoteTimeLabel.text = startingDate?.getHour()
        self.adresseLabel.isHidden = self.timenoteDto.location == nil
        self.adresseLabel.text = self.timenoteDto.location?.address.address
        self.setTimenoteDescription()
    }
    
    private func setTimenoteImages() {
        if let hexColor = self.timenoteDto?.colorHex, !hexColor.isEmpty {
            let color = UIColor(hex: hexColor)!
            let imageColor = UIImage(color: color, size: CGSize(width: self.timenoteImageView.frame.width, height: self.timenoteImageView.frame.height))
            let imageSource = ImageSource(image: imageColor!)
            self.timenoteImageView.setImageInputs([imageSource])
            return
        }
        var timenoteImages : [SDWebImageSource] = []
        self.timenoteDto?.pictures.forEach({if let sdImage = SDWebImageSource(urlString: $0) { timenoteImages.append(sdImage) } })
        self.timenoteImageView.setImageInputs(timenoteImages)
        self.setPagerNumberItems(numberItems: timenoteImages.count)
    }
    
    private func setTimenoteDescription() {
        let addedAttributedString = NSAttributedString(string: self.timenoteDto?.description ?? "", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Light", size: 14)!])
        
        self.timenoteDesciptionLabel.attributedText = addedAttributedString
    }
    
    private func setPagerNumberItems(numberItems: Int) {
        self.pagerControll.isHidden = numberItems <= 1
        self.pagerControll.currentPage = 0
        self.pagerControll.numberOfPages = numberItems
    }
}

extension PreviewTimenoteViewController : ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        self.pagerControll.currentPage = page
    }
}

extension PreviewTimenoteViewController : FollowingSelectedDelegate {
    func didSelect(users: [String]) {
        self.usersIdShare = users
    }
}
