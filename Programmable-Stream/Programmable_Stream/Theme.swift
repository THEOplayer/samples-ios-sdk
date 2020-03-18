//
//  Theme.swift
//  Programmable_Stream
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit

extension UIFont {
    static var theoTitle: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }

    static var theoText: UIFont {
        return UIFont.systemFont(ofSize: 14)
    }

    static func theoFont(ofSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: ofSize)
    }
}

extension UIColor {
    static var theoWhite: UIColor {
        // #FFFFFF
        return UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1.0)
    }
    static var theoBlack: UIColor {
        // #000000
        return UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    static var theoStarDust: UIColor {
        // #989897
        return UIColor(displayP3Red: 152 / 255, green: 152 / 255, blue: 151 / 255, alpha: 1.0)
    }
    static var theoCello: UIColor {
        // #344A5E
        return UIColor(displayP3Red: 52 / 255, green: 74 / 255, blue: 94 / 255, alpha: 1.0)
    }
    static var theoBermudaGrey: UIColor {
        // #7293A4
        return UIColor(displayP3Red: 114 / 255, green: 147 / 255, blue: 164 / 255, alpha: 1.0)
    }
    static var theoEchoBlue: UIColor {
        // #9CB9C9
        return UIColor(displayP3Red: 156 / 255, green: 185 / 255, blue: 201 / 255, alpha: 1.0)
    }
    static var theoLinkWater: UIColor {
        // #CED9E1
        return UIColor(displayP3Red: 206 / 255, green: 217 / 255, blue: 225 / 255, alpha: 1.0)
    }
    static var theoLightYellow: UIColor {
        // #FFF3D4
        return UIColor(displayP3Red: 255 / 255, green: 243 / 255, blue: 212 / 255, alpha: 1.0)
    }
    static var theoLightningYellow: UIColor {
        // #FFC713
        return UIColor(displayP3Red: 255 / 255, green: 199 / 255, blue: 19 / 255, alpha: 1.0)
    }
}
