//
//  ProfileManagementViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 9/10/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ProfileManagementViewController : UIViewController {
    
    @IBOutlet weak var userLocalisationStackView: UIStackView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    var configurationViewDelegate: ConfigurationViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profilViewController = segue.destination as? ProfileViewController {
            profilViewController.user = UserManager.shared.userInformation
            profilViewController.forceShow = true
        }
        if let configuraitonViewController = segue.destination as? ConfigurationViewController {
            configuraitonViewController.delegate = configurationViewDelegate
        }
    }
    
    func configure() {
        if let picture = UserManager.shared.userInformation?.picture, let url = URL(string: picture) {
            DispatchQueue.main.async { [weak self] in
                self?.userImageView.sd_setImage(with: url)
            }
        }
        self.userNameLabel.text = UserManager.shared.userInformation?.userName
        self.userLocalisationStackView.isHidden =  UserManager.shared.userInformation?.location == nil
        self.userLocationLabel.text = UserManager.shared.userInformation?.location?.address.address
    }
    
    @IBAction func addFriendIsTapped(_ sender: Any) {
        self.present(UIActivityViewController(activityItems: ["http://itunes.apple.com/us/app/968738944"], applicationActivities: nil), animated: true)
    }
    
    @IBAction func prefIsTapped(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "showPreference", sender: self)
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
