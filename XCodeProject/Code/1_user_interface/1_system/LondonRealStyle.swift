//
//  LondonRealStyle.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 11/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit

class LondonRealStyle
{
    static let screenPadding: Float = 40
    static var screenPaddingCGFloat: CGFloat
    {
        get
        {
            return CGFloat(screenPadding)
        }
    }
}

extension UIFont
{
    static func LondonReal(_ size: Float = 30) -> UIFont
    {
        guard let font = OswaldLight(size) else
        {
            return UIFont.systemFont(ofSize: CGFloat(size))
        }
        
        return font
    }
    
    static func LondonRealLarge() -> UIFont
    {
        return UIFont.LondonReal(42)
    }
    
    static func LondonRealHeadline(_ size: Float = 60) -> UIFont
    {
        guard let font = BebasRegular(size) else
        {
            return UIFont.systemFont(ofSize: CGFloat(size))
        }
        
        return font
    }
    
    static func OswaldLight(_ size: Float) -> UIFont?
    {
        return UIFont(name: "Oswald-Light", size: CGFloat(size))
    }
    
    static func OswaldRegular(_ size: Float) -> UIFont?
    {
        return UIFont(name: "Oswald-Regular", size: CGFloat(size))
    }
    
    static func OswaldBold(_ size: Float) -> UIFont?
    {
        return UIFont(name: "Oswald-Bold", size: CGFloat(size))
    }
    
    static func BebasRegular(_ size: Float) -> UIFont?
    {
        return UIFont(name: "BebasNeueRegular", size: CGFloat(size))
    }
}

extension UIColor
{
    static func LondonRealBackground() -> UIColor
    {
        return LondonRealBlack()
    }
    
    static func LondonRealFocusedText() -> UIColor
    {
        return LondonRealRed()
    }
    
    static func LondonRealUnfocusedText() -> UIColor
    {
        return UIColor.white
    }
    
    static func LondonRealRed() -> UIColor
    {
        return UIColor(red: 199.0/255, green: 33.0/255, blue: 40.0/255, alpha: 1.0)
    }
    
    static func LondonRealBlack() -> UIColor
    {
        return UIColor(red: 39.0/255, green: 48.0/255, blue: 56.0/255, alpha: 1.0)
    }
}
