//
//  TimenoteXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 7/5/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class TimenoteXibView : UITableViewCell {
    
    @IBOutlet weak var timenoteNameLabel: UILabel!
    @IBOutlet weak var timenoteYearLabel: UILabel!
    @IBOutlet weak var timenoteDayLabel: UILabel!
    @IBOutlet weak var timenoteMonthLabel: UILabel!
    @IBOutlet weak var timenoteTimeLabel: UILabel!
    @IBOutlet weak var timenoteDesciptionLabel: UILabel!
    
    @IBAction func timenoteLikeIsTapped(_ sender: UIButton) {
    }
    
    @IBAction func timenoteCommentIsTapped(_ sender: UIButton) {
    }
    
    @IBAction func timenoteAddIsTapped(_ sender: UIButton) {
    }
    
}
