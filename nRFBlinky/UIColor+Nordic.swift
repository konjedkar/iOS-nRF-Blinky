//
//  UIColor+Nordic.swift
//  nRFBlinky
//
//  Created by Aleksander Nowakowski on 12/02/2019.
//  Copyright © 2019 Nordic Semiconductor ASA. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == .light ? light : dark
            }
        } else { 
            return light
        }
    }
    
    static let nordicBlue = #colorLiteral(red: 0, green: 0.7181802392, blue: 0.8448022008, alpha: 1)
    
    static let nordicRed = #colorLiteral(red: 0.9567440152, green: 0.2853084803, blue: 0.3770255744, alpha: 1)
    
    static let gregoryBlue = #colorLiteral(red: 0, green: 0.2901960784, blue: 0.5019607843, alpha: 1)
    
    static let colorBorder = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8470588235)
    
    static let colorTimeNormal = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    static let colorAlarm = #colorLiteral(red: 0.9450980392, green: 0.337254902, blue: 0.137254902, alpha: 1)
    
    
    

    
    
    
    
}
