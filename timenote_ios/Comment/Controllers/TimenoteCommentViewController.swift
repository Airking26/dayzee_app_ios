//
//  CommentTimenoteViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/25/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class TimenoteCommentViewController : UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    public var timenoteId  : String?   = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.configureTextViewPlaceholder()
    }

    @IBAction func backIsTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func configureTextViewPlaceholder() {
        self.textView.text = "Ajouter un commentaire"
        self.textView.textColor = UIColor.lightGray
    }
    
    @IBAction func publichIsTapped(_ sender: UIButton) {
        self.textView.text = ""
        self.configureTextViewPlaceholder()
        self.view.endEditing(true)
    }
}

extension TimenoteCommentViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.configureTextViewPlaceholder()
        }
    }
    
}
