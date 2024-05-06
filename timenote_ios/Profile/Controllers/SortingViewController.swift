//
//  SortingViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/6/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class SortingViewController : UIViewController {
    
    /* IBOUTLET */
    
    @IBOutlet weak var sortedTableView: UITableView!
    
    /* VARIABLES */
    
    static let SortingCellName  : String    = "TimenoteWithHeaderXibView"
    
    /* OVERRIDE */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sortedTableView.register(UINib(nibName: SortingViewController.SortingCellName, bundle: nil), forCellReuseIdentifier: SortingViewController.SortingCellName)
    }
    
    /* IBACTION */
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SortingViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sortedTableView.dequeueReusableCell(withIdentifier: SortingViewController.SortingCellName)!
    }
    
}
