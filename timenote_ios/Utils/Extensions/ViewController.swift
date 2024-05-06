//
//  ViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 6/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

struct ErrorMessageContactHandler {
    static let mailErrorMessage = "Il est impossible d'envoyer un mail depuis cette appareil veuillez réessayer ultérieurement"
    
    static let noMailMessage = "Il est impossible d'envoyer un mail depuis cette appareil veuillez réessayer ultérieurement"
    
    static let emptyNumberMessage = "Il est impossible d'envoyer un mail depuis cette appareil veuillez réessayer ultérieurement"
    
    static let callErrorMessage = "Il est impossible d'envoyer un mail depuis cette appareil veuillez réessayer ultérieurement"
    
    static let textErrorMessage = "Il est impossible d'envoyer un mail depuis cette appareil veuillez réessayer ultérieurement"
}

extension UIViewController {
    
    func popAlertView(title: String, desc: String) {
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            @unknown default:
                print("None")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    /*
     Make the naviguation bar appear and clear the background color to clear
     */
    
    func hideNaviguationBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func showNaviguationBar() {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func hideBackBarButton() {
        self.navigationItem.hidesBackButton = true
    }
    
    func showBackBarButton() {
        self.navigationItem.hidesBackButton = false
    }
    
    func clearNaviguationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    func setNaviguationBarBackground(_ image : UIImage?) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(image ?? UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    /*
     Change the style of the back button of the naviguation bar to the Adoklok design
     */
    
    func makeCustomBackBarButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    func makeCustomBackBarButton(_ title : String?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: title ?? "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    func makeCustomBackBarButton(_ title : String? ,  _ target : Any?, _ selector : Selector?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: title ?? "", style: UIBarButtonItem.Style.plain, target: target, action: selector)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    func setBackBarImage(_ image : UIImage) {
        self.navigationController?.navigationBar.backIndicatorImage = image
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
    }
    
    func makeCustomBackBarButtonWithImage(_ title : String? , _ image : UIImage) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: title ?? "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = image
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
    }
    
    /*
     Chage the title of the naviguation bar
     */
    
    func setTitleAndColorNaviguationBar(_ title : String?, _ color : UIColor) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }
    
    func setTitleAndFontNaviguationBar(_ title : String?, _ font : String, _ size : CGFloat) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: font, size: size)!]
    }
    
    func setTitleNaviguationBar(_ title : String?) {
        self.navigationItem.title = title
    }
    
    func setTitleColorNaviguationBar(_ color : UIColor) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }
    
    func setTitleFontNaviguationBar(_ font : String, _ size : CGFloat) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: font, size: size)!]
    }
    
    func setTitleAndFontAndColorNaviguationBar(_ title : String?, _ font : String, _ size : CGFloat, _ color : UIColor) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: font, size: size)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }
    
    func setTitleAsImage(_ image : UIImage) {
        self.navigationItem.titleView = UIImageView(image: image)
    }
    
    /*
     Add a right item to the naviguation bar
     */
    
    func setRightButtonNaviguationBar(_ title : String?) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title ?? "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
    
    func setRightButtonNaviguationBar(_ title : String?, _ selector : Selector?,  _ sender : Any?, _ color : UIColor?) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title ?? "", style: UIBarButtonItem.Style.plain, target: sender, action: selector)
        self.navigationItem.rightBarButtonItem?.tintColor = color
    }
    
    /*
     Add a left button at the same place than the back bar button
     */
    
    func setLeftAtBactBarButton(_ title : String?, _ image : UIImage?, _ selector : Selector?, _ target : Any?) {
        let newBackButton = UIBarButtonItem(title: title , style: UIBarButtonItem.Style.plain, target: target, action: selector)
        newBackButton.setBackgroundImage(image, for : .normal, barMetrics: .default)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    func setLeftAtBactBarButton(_ image : UIImage?, _ selector : Selector?, _ target : Any?) {
        let newBackButton = UIBarButtonItem(title: nil , style: UIBarButtonItem.Style.plain, target: target, action: selector)
        newBackButton.setBackgroundImage(image, for : .normal, barMetrics: .default)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    /*
     Animation when the text editing will hide
     */
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.view.transform = .identity
        }
    }
    
    /*
     Animation when the text editing will show
     */
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard self.view.transform == .identity else {return}
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.2) {
                self.view.transform = CGAffineTransform(translationX: 0.0, y: -keyboardHeight / 2.0)
            }
        }
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    /*
     Only need to be called once in viewDidLoad() to make an animation on an edition of the text.
     Plus it make the text deasepear if we touch outside the text editing area
     */
    func hideKeyboardOnTouchOutside() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardDidHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func hideKeyboardOnTouchOutsideWithoutAnimation() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        view.addGestureRecognizer(tap)
    }

    /* Function to make a call it handle errors with a popup message */
    
    func callNumber(_ number : String) {
        guard number.isEmpty else {
            let selectSourceController = UIAlertController(title: nil, message: ErrorMessageContactHandler.emptyNumberMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style : UIAlertAction.Style.cancel)
            selectSourceController.addAction(cancelAction)
            self.present(selectSourceController, animated: true, completion: nil)
            return
        }
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func textNumber(_ numbers : [String]) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.recipients = numbers
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        } else {
            let selectSourceController = UIAlertController(title: nil, message: ErrorMessageContactHandler.textErrorMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style : UIAlertAction.Style.cancel)
            selectSourceController.addAction(cancelAction)
            self.present(selectSourceController, animated: true, completion: nil)
        }
    }
    
    func mailAdresses(from : String?, to : [String]?, subject : String, body: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(to)
            mailVC.setSubject(subject)
            mailVC.setMessageBody(body, isHTML: false)
            self.present(mailVC, animated: true, completion: nil)
        } else {
            let selectSourceController = UIAlertController(title: nil, message: ErrorMessageContactHandler.mailErrorMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style : UIAlertAction.Style.cancel)
            selectSourceController.addAction(cancelAction)
            self.present(selectSourceController, animated: true, completion: nil)
        }
    }
    public var isVisible: Bool {
        if isViewLoaded {
            return view.window != nil
        }
        return false
    }
    
    var isShowed : Bool { get {
        if self.navigationController != nil {
            return self.navigationController?.visibleViewController === self
        } else if self.tabBarController != nil {
            return self.tabBarController?.selectedViewController == self && self.presentedViewController == nil
        } else {
            return self.presentedViewController == nil && self.isVisible
        }
    }}
    
}

extension UIViewController : MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension UIViewController : MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
