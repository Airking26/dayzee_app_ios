//
//  Navigation.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func clearNavigationBar() {
        self.isNavigationBarHidden = false
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
    }
    
    func hideNavigationBar() {
        self.isNavigationBarHidden = true
    }
    
    func unhideNavigationBar() {
        self.isNavigationBarHidden = false
    }
}

extension UINavigationItem {
    func changeBackBarTitle(_ title : String?) {
        self.leftBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        self.leftBarButtonItem?.tintColor = UIColor.white
    }
}
