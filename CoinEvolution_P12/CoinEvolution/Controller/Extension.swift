//
//  Extension.swift
//  CoinEvolution
//
//  Created by Déborah Suon on 31/07/2022.
//

import Foundation
import UIKit

extension UIViewController {
    /// Create an extension UIVC to have a common fonction commune to viewcontrollers
    func setGradientBackground(viewToChange: UIView) {
        let colorTop =  UIColor(red: 0/255, green: 147/255, blue: 190/255, alpha: 1.0).cgColor
        let colorBottom =
        UIColor(red: 0/255, green: 23/255, blue: 255/255, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = viewToChange.bounds
        
        viewToChange.layer.insertSublayer(gradientLayer, at:0)
        viewToChange.layer.cornerRadius = 10
        viewToChange.layer.masksToBounds = true
    }
}
