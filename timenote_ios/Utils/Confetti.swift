//
//  Confetti.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

public class Confetti: UIView {

    private var emitter: CAEmitterLayer!
    private var intensity: Float = 1

    private var colors: [UIColor]  {
       return [
            UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
            UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
            UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
            UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
            UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)
        ]
    }

    public func startConfettis() {
        emitter = CAEmitterLayer()

        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape    = CAEmitterLayerEmitterShape.line
        emitter.emitterSize     = CGSize(width: frame.size.width, height: 1)

        var cells: [CAEmitterCell] = []

        for color in colors {
            cells.append(createConfetti(color: color))
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
    }

    public func stopConfettis() {
        emitter?.birthRate = 0
    }

    private func createConfetti(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = .pi
        confetti.emissionRange = .pi / 4
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = UIImage(named: "confetti")!.cgImage
        return confetti
    }
}

extension UIViewController {
    public func animateVCWithConfetti() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = 15
        blurEffectView.frame = view.frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let confetti = Confetti(frame: blurEffectView.frame)
        
        blurEffectView.contentView.addSubview(confetti)
        blurEffectView.alpha = 0
        view.addSubview(blurEffectView)
        blurEffectView.makeAppear(1)
        confetti.startConfettis()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            confetti.makeDisappear(1.0)
            blurEffectView.makeDisappear(1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                confetti.stopConfettis()
                blurEffectView.removeFromSuperview()
            }
        }
    }
}
