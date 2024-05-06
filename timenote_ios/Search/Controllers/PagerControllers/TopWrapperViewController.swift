//
//  TopWrapperViewController.swift
//  Timenote
//
//  Created by Dev on 12/6/21.
//  Copyright © 2021 timenote. All rights reserved.
//

import UIKit

class TopWrapperViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setVC()
    }
    
    private func setVC() {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "TopViewController")
        self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }

}
