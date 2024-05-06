    //
    //  AlertManager.swift
    //  Timenote
    //
    //  Created by Aziz Essid on 6/8/20.
    //  Copyright © 2020 timenote. All rights reserved.
    //
    
    import Foundation
    import SwiftEntryKit
    
    class AlertManager {
        
        static let shared = AlertManager()
        
        private var missedGoogleEventsAlertIsShoved: Bool = false
        
        private func getErrorEKAttribute(isBlue: Bool, position: EKAttributes.Position) -> EKAttributes {
            var attributes = EKAttributes()
            attributes.windowLevel = .alerts
            attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
            attributes.position = position
            attributes.displayDuration = 2
            attributes.screenInteraction = .dismiss
            attributes.scroll = .disabled
            let colors = isBlue ? [EKColor(#colorLiteral(red: 0, green: 0.3269676566, blue: 0.6329476237, alpha: 1)),EKColor(#colorLiteral(red: 1, green: 0.2633090019, blue: 0.4340131283, alpha: 1))] : [EKColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)),EKColor(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))]
            attributes.entryBackground = .gradient(gradient: .init(colors: colors, startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
            return attributes
        }
        
        func showErrorWithTilteAndDesciption(title: String, desciption: String, isBlue: Bool = false, position: EKAttributes.Position = .top) {
            let title = EKProperty.LabelContent(
                text: title,
                style: EKProperty.LabelStyle(
                    font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium),
                    color: .white)
            )
            let description = EKProperty.LabelContent(
                text: desciption,
                style: EKProperty.LabelStyle(
                    font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium),
                    color: .white)
            )
            let image = EKProperty.ImageContent(
                image: UIImage(),
                size: CGSize(width: 0, height: 0)
            )
            let simpleMessage = EKSimpleMessage(
                image: image,
                title: title,
                description: description
            )
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: self.getErrorEKAttribute(isBlue: isBlue, position: position))
        }
        
        public func showIncorrectCredential() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "L'addresse mail ou le mot de passe est incorrect" : "The email adress or the password is incorrect", desciption: "")
        }
        
        public func showIncorrectTitle() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Un titre est nécessaire" : "A title is need", desciption: "")
        }
        
        public func showIncorrectLink() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Le lien est incorrecte" : "Link is not valid", desciption: "")
        }
        
        public func showIncorrectDate() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Le date de début est incorrecte" : "Start date is not valid", desciption: "")
        }
        
        public func showIncorrectEndDate() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Le date de fin est incorrecte" : "End date is not valid", desciption: "")
        }
        
        public func showNeedPicture() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Une image ou une couleur est nécessaire" : "A picture or a color is need", desciption: "")
        }
        
        public func showNeedPrice() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "La devise est le prix sont nécessaire" : "Price and currency are needed", desciption: "")
        }
        
        public func showMissingTextField() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Veuillez remplir tous les champs" : "Please fill al fields", desciption: "")
        }
        
        public func showIncorrectPassword() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Les mots de passe ne correspondent pas" :"Passwords does not match", desciption: "")
        }
        
        public func showEmailInvalid() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "L'adresse email est invalide" :"Email adress is invalid or already used", desciption: "")
        }
        
        public func showCGUNotChecked() {
            self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Veuillez valider les CGU" :"Please agree to the terms", desciption: "")
        }
        
        public func showGoogleMissedEvents(numberOfImportedEvents imported: Int,
                                           totalNumberOfEvents total: Int,
                                           offset: Int,
                                           showAgain: Bool? = nil) {
            if !missedGoogleEventsAlertIsShoved || showAgain ?? false {
                self.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "\(imported) évènements ont été importés à partir de Google Calendar sur \(total) en tout" : "\(imported) events from google calendar imported on \(total) total", desciption: "", isBlue: true, position: .bottom)
                missedGoogleEventsAlertIsShoved = true
            }
        }
        
        
        private func getErrorEKAttribute() -> EKAttributes {
            //        [EKColor(rgb: 0xFDB777), EKColor(rgb: 0xFDA766),EKColor(rgb: 0xFD9346),EKColor(rgb: 0xFD7F2C),EKColor(rgb: 0xFF6200)]
            var attributes = EKAttributes()
            attributes = EKAttributes.centerFloat
            attributes.hapticFeedbackType = .success
            attributes.displayDuration = .infinity
            attributes.entryBackground = .gradient( gradient: .init( colors: [EKColor(rgb: 0xFFC107),EKColor(rgb: 0xE91E63)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)) )
            attributes.shadow = .active(
                with: .init(
                    color: .black,
                    opacity: 0.3,
                    radius: 8
                )
            )
            attributes.entryInteraction = .absorbTouches
            attributes.scroll = .enabled(
                swipeable: false,
                pullbackAnimation: .jolt
            )
            attributes.entranceAnimation = .init(
                translate: .init(
                    duration: 0.7,
                    spring: .init(damping: 0.7, initialVelocity: 0)
                ),
                scale: .init(
                    from: 0.7,
                    to: 1,
                    duration: 0.4,
                    spring: .init(damping: 1, initialVelocity: 0)
                )
            )
            attributes.exitAnimation = .init(
                translate: .init(duration: 0.2)
            )
            attributes.popBehavior = .animated(
                animation: .init(
                    translate: .init(duration: 0.35)
                )
            )
            attributes.positionConstraints.size = .init(
                width: .offset(value: 30),
                height: .intrinsic
            )
            return attributes
        }
        
        public func showPopup(title: String, message: String) {
            let title       = EKProperty.LabelContent(text: title, style: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold), color: .white))
            let description = EKProperty.LabelContent(text: message, style: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), color: .white))
            let button      = EKProperty.ButtonContent(
                label: .init(text: "OK", style: .init(font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), color: EKColor(.orange), displayMode: .light)),
                backgroundColor: .white,
                highlightedBackgroundColor: .white,
                displayMode: .light)
            
            let action      = EKPopUpMessage(title: title, description: description, button: button) {
                SwiftEntryKit.dismiss()
            }
            let contentView = EKPopUpMessageView( with: action)
            
            SwiftEntryKit.display(entry: contentView, using: self.getErrorEKAttribute())
        }
        
        public func showPopupWithAction(title: String, message: String, buttonText: String = "OK", completion: @escaping () -> Void) {
            let title       = EKProperty.LabelContent(text: title, style: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold), color: .white))
            let description = EKProperty.LabelContent(text: message, style: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), color: .white))
            let button      = EKProperty.ButtonContent(
                label: .init(text: buttonText, style: .init(font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), color: EKColor(.orange), displayMode: .light)),
                backgroundColor: .white,
                highlightedBackgroundColor: .white,
                displayMode: .light)
            
            let action      = EKPopUpMessage(title: title, description: description, button: button) {
                completion()
            }
            let contentView = EKPopUpMessageView(with: action)
            
            SwiftEntryKit.display(entry: contentView, using: self.getErrorEKAttribute())
        }
        
        public func showPopupWithCancelAction(title: String, message: String, buttonText: String = "OK", completion: @escaping () -> Void) {
            let title       = EKProperty.LabelContent(text: title, style: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold), color: .white))
            let description = EKProperty.LabelContent(text: message, style: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), color: .white))
            
            let button      = EKProperty.ButtonContent(
                label: .init(text: buttonText, style: .init(font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), color: EKColor(.white), displayMode: .light)),
                backgroundColor: .clear,
                highlightedBackgroundColor: .white,
                displayMode: .light) {
                completion()
            }
            
            let button2 = EKProperty.ButtonContent(
                label: .init(text: NSLocalizedString("Cancel", comment: ""), style: .init(font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), color: EKColor(.white), displayMode: .light)),
                backgroundColor: .clear,
                highlightedBackgroundColor: EKColor(.red),
                displayMode: .light) {
                SwiftEntryKit.dismiss()
            }
            
            let simpleMessage = EKSimpleMessage(
                title: title,
                description: description
            )
            
            let buttonsBarContent = EKProperty.ButtonBarContent(
                with: button, button2,
                separatorColor: EKColor(.orange),
                horizontalDistributionThreshold: 2,
                displayMode: .light,
                expandAnimatedly: true
            )
            
            let alertMessage = EKAlertMessage(
                simpleMessage: simpleMessage,
                buttonBarContent: buttonsBarContent
            )
            
            let contentView = EKAlertMessageView(with: alertMessage)
            SwiftEntryKit.display(entry: contentView, using: self.getErrorEKAttribute())
        }
        
        public func showForm(title: String, placeholder: String, completion: @escaping (String) -> Void) {
            let title = EKProperty.LabelContent(text: title, style: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold), color: .white))
            let field = EKProperty.TextFieldContent(placeholder: EKProperty.LabelContent(text: placeholder, style: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular), color: EKColor(.darkGray))), textStyle: EKProperty.LabelStyle(font: UIFont.systemFont(ofSize: 16), color: .white, alignment: .left, displayMode: .light, numberOfLines: 1) )
            
            let button = EKProperty.ButtonContent(
                label: .init(text: NSLocalizedString("Validate", comment: ""), style: .init(font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium), color: EKColor(.white), displayMode: .light)),
                backgroundColor: .clear,
                highlightedBackgroundColor: EKColor(.red),
                displayMode: .light) {
                if !field.textContent.isEmpty {
                    completion(field.textContent)
                    print(field.textContent)
                }
            }
            
            let contentView = EKFormMessageView(
                with: title,
                textFieldsContent: [field],
                buttonContent: button
            )
            var attributes = getErrorEKAttribute()
            attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
                
        public func showRepoAlert(presentAlert: @escaping (UIAlertController) -> Void,
                                  alertAction: @escaping (String?) -> Void) {
            let alert = UIAlertController(title: "reportAnswer".localized,
                                          message: "reportDescription".localized,
                                          preferredStyle: .actionSheet)
            
            ReportType.allCases.forEach {
                alert.addAction(UIAlertAction(title: $0.rawValue.localized,
                                              style: .default,
                                              handler: { action in
                                                alertAction(action.title)
                                              }))
            }
            
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            alert.addAction(cancelAction)
            
            presentAlert(alert)
        }
        
    }
