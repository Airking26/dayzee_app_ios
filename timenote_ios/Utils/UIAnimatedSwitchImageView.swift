//
//  UIAnimatedImageView.swift
//  Timenote
//
//  Created by Aziz Essid on 6/9/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol UIAnimatedSwitchImageViewDelegate {
    func willStartSwitch(currentImageIndex: Int)
    func willSwitchImages(currentImageIndex: Int, newImageIndex: Int)
    func didSwitchImages(newImageIndex: Int)
    func didStoppedAnimation()
}

// Class that will handle the animation automatic switch of images in the same UIImages
class UIAnimatedSwitchImageView : UIImageView {
    
    // Default duration of the switch animation
    private static let animationSwitchDefaultAnimationDuration   : TimeInterval  = 1.0
    private static let animationSwitchDefaultTickTimerDuration   : TimeInterval  = 1.0

    // Animation Switch added variables
    private var animationSwitchTimer        : Timer?                                = nil   // Timer that will handle the animation tick
    public  var animationSwitchImages       : [UIImage?]                            = []    // Images that will switch on timer tick
    public  var animationSwitchDuration     : TimeInterval                          = 1.0   // Duration of the animation on timer tick
    public  var animationSwitchTick         : TimeInterval                          = 1.0   // Duration of delay between each timer tick
    public  var animationSwitchIsRestarting : Bool                                  = true  // Define if the animation should repeat indefinitly
    public  var animationSwitchDelegate     : UIAnimatedSwitchImageViewDelegate?    = nil
    public  var animationSwitchIndex        : Int                                   = 0     // Index that define the current Image index of the animation
    private var animationSwitchIsAnimating  : Bool                                  = false // Boolean to define if the class is making a switch animation
    
    // Set the animation duration to do the switch of images
    public func setAnimationSwitchDuration(animationSwitchDuration: TimeInterval?) {
        self.animationSwitchDuration = animationSwitchDuration ?? UIAnimatedSwitchImageView.animationSwitchDefaultAnimationDuration
    }
    
    // Set the animation tick interval to do the switch of images
    public func setAnimationSwitchTickInterval(animationSwitchTickInterval: TimeInterval?) {
        self.animationSwitchTick = animationSwitchTickInterval ?? UIAnimatedSwitchImageView.animationSwitchDefaultTickTimerDuration
    }
    
    // Start the switch animation of the animationSwitchImages and all the animationSwitchDuration indexes
    public func startSwitchAnimation() {
        // Set the boolean to define animation has started
        self.animationSwitchIsAnimating = true
        // Reset the switch index of images
        self.animationSwitchIndex = 0
        // Create the timer to call our animation
        self.animationSwitchTimer = Timer.scheduledTimer(timeInterval: self.animationSwitchTick, target: self, selector: #selector(self.makeSwitchAnimation), userInfo: nil, repeats: true)
    }
    
    // Stop all the animation and reset animation indexes
    public func stopSwitchAnimation() {
        // Set the boolean to define animation has stoped
        self.animationSwitchIsAnimating = false
        // Reset the switch index of images
        self.animationSwitchIndex = 0
        // Stop the timer to tick
        self.animationSwitchTimer?.invalidate()
        // Call delegate
        self.animationSwitchDelegate?.didStoppedAnimation()
    }
    
    // Check if for the currentIndex and the currentImages animation can continue
    private func newAnimationIndex() -> Int? {
        let isNotInRange        = self.animationSwitchIndex < self.animationSwitchImages.count - 1
        let isInRangeButRestart = self.animationSwitchIndex == self.animationSwitchImages.count - 1 && self.animationSwitchIsRestarting
        guard isNotInRange || isInRangeButRestart else { return nil }
        return isNotInRange ? self.animationSwitchIndex + 1 : 0
    }
    
    // Make the switch animation between the animationSwitchImages
    @objc func makeSwitchAnimation() {
        // Check if the last image has not been done
        guard let newIndex = self.newAnimationIndex() else { return self.stopSwitchAnimation() }
        // Call delegate
        self.animationSwitchDelegate?.willStartSwitch(currentImageIndex: self.animationSwitchIndex)
        // Start making the deseapear animation
        UIView.animate(withDuration: self.animationSwitchDuration, animations: {
            // Change Alpho for animation
            self.alpha = 0.5
        }) { (finished) in
            guard finished else { return }
            // Call delegate
            self.animationSwitchDelegate?.willSwitchImages(currentImageIndex: self.animationSwitchIndex, newImageIndex: newIndex)
            // Change image
            self.image = self.animationSwitchImages[newIndex]
            // Set new index
            self.animationSwitchIndex = newIndex
            // Make new animation
            UIView.animate(withDuration: self.animationSwitchDuration, animations: {
                // Reset alpha
                self.alpha = 1
            }) { (finished) in
                // Call delegate
                self.animationSwitchDelegate?.didSwitchImages(newImageIndex: self.animationSwitchIndex)
            }
            // Check if the last image has been done
            guard self.newAnimationIndex() != nil else { return self.stopSwitchAnimation() }
        }
    }
}
