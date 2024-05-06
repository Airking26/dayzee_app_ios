//
//  WebContentVC.swift
//  Dayzee
//
//  Created by Dev on 1/21/22.
//  Copyright © 2022 timenote. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class WebContentVC: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var contentURl: URL?
    
// MARK: Override methods
    
    override func viewDidLoad() {
        self.initUI()
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
        self.presentContent()
    }
    
// MARK: Private methods
    
    private func initUI() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
    }
    
    private func presentContent() {
        guard let url = contentURl else { return }
        webView.load(URLRequest(url: url))
    }

}
