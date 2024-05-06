//
//  SectionFollowersViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/26/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class SectionFollowersViewController : UIViewController {
    
    @IBOutlet weak var followersTableview: UITableView!
    @IBOutlet weak var sectionLabel: UILabel!
    
    private var categorie       : CategorieDto? = nil
    static  let ListCellName    : String        = "FollowerXibView"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.followersTableview.register(UINib(nibName: SectionFollowersViewController.ListCellName, bundle: nil), forCellReuseIdentifier: SectionFollowersViewController.ListCellName)
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SectionFollowersViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.followersTableview.dequeueReusableCell(withIdentifier: SectionFollowersViewController.ListCellName)!
    }
    
    
}
