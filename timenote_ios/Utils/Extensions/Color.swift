//
//  Color.swift
//  Timenote
//
//  Created by Aziz Essid on 10/11/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            var r:CGFloat = 0
            var g:CGFloat = 0
            var b:CGFloat = 0
            var a:CGFloat = 0
            if getRed(&r, green: &g, blue: &b, alpha: &a) {
                return (r,g,b,a)
            }
            return (0,0,0,0)
        }
        // hue, saturation, brightness and alpha components from UIColor**
        var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
            var hue:CGFloat = 0
            var saturation:CGFloat = 0
            var brightness:CGFloat = 0
            var alpha:CGFloat = 0
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
                return (hue,saturation,brightness,alpha)
            }
            return (0,0,0,0)
        }
        var htmlRGBColor:String {
            return String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255), Int(rgbComponents.alpha))
        }
    
    public convenience init?(hex: String) {
            let r, g, b: CGFloat
            if hex.hasPrefix("#") {
                let start = hex.index(hex.startIndex, offsetBy: 1)
                var hexColor = String(hex[start...])
                if hexColor.count >= 6 {
                    if hexColor.count == 6 {
                        hexColor.append("00")
                    }
                    let scanner = Scanner(string: hexColor)
                    var hexNumber: UInt64 = 0

                    if scanner.scanHexInt64(&hexNumber) {
                        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                        //a = CGFloat(hexNumber & 0x000000ff) / 255

                        self.init(red: r, green: g, blue: b, alpha: 255)
                        return
                    }
                }
            }

            return nil
        }
}
