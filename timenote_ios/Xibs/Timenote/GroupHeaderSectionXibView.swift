//
//  GroupHeaderSectionXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 05/12/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol GroupSectionDelegate {
    func didCollapse(section: Int?)
    func didSelect(section: Int?)
}

struct UserGroup       : Hashable {
    let user        : UserResponseDto
    let name        : String
}

struct GroupSectionDto : Hashable {
    let group       : [UserGroup]
    var name        : String
    var selected    : Bool
    var collapsed   : Bool
}
    
class GroupHeaderSectionXibView : UITableViewHeaderFooterView {
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleSection: UILabel!
    @IBOutlet weak var collapseButton: UIButton!
        
    private var delegate    : GroupSectionDelegate?     = nil
    private var section     : Int?                      = nil
    private var selected    : Bool                      = false
        
    public func configure(delegate: GroupSectionDelegate?, section: Int?, group: GroupSectionDto) {
        self.delegate = delegate
        self.section = section
        DispatchQueue.main.async {
            self.collapseButton.isSelected = group.collapsed
            self.titleSection.text = group.name
            self.selected = group.selected
            self.selectButton.backgroundColor = self.selected ? .link : .clear
        }
    }

    @IBAction func collapseIsTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            sender.isSelected = !sender.isSelected
        }
        self.delegate?.didCollapse(section: self.section)
    }

    @IBAction func selectIsTapped(_ sender: UIButton) {
        self.delegate?.didSelect(section: self.section)
    }
}
