//
//  Theme.swift
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import UIKit

extension UIFont {
    static var dolbyTitle: UIFont {
        return UIFont.systemFont(ofSize: 18)
    }

    static var dolbyText: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }

    static func dolbyFont(ofSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: ofSize)
    }
}

extension UIColor {
    static var dolbyWhite: UIColor {
        // #FFFFFF
        return UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1.0)
    }
    static var dolbyBlack: UIColor {
        // #000000
        return UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    static var dolbyPurple: UIColor {
        // #8339FC
        return UIColor(displayP3Red: 0.514, green: 0.224, blue: 0.988, alpha: 0.7)
    }
    static var dolbyBlue: UIColor {
        // #3E44FE
        return UIColor(displayP3Red: 0.243, green: 0.267, blue: 0.996, alpha: 1.0)
    }
    static var dolbyTransparentBlue: UIColor {
        // #3E44FE
        return UIColor(displayP3Red: 0.243, green: 0.267, blue: 0.996, alpha: 0.3)
    }
}
