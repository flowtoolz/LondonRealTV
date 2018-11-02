//
//  FocusableView.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 25/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit

class FocusableView: UIButton
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setShadow(UIView.shadowNormal)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Animate Focus
    
    override func didUpdateFocus(in context: UIFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator)
    {
        super.didUpdateFocus(in: context, with: coordinator)
        
        self.superview?.bringSubview(toFront: self)

        if context.nextFocusedView == self
        {
            coordinator.addCoordinatedAnimations(
            {
                self.backgroundColor = self.normalBackgroundColor.brighter(1.2)
                self.setScaleElevated()
                self.setShadowElevatedAnimated(UIView.inheritedAnimationDuration)
            },
            completion:nil)
        }
        else
        {
            coordinator.addCoordinatedAnimations(
            {
                self.backgroundColor = self.normalBackgroundColor
                self.setScaleNormal()
                self.setShadowNormalAnimated(UIView.inheritedAnimationDuration)
            },
            completion:nil)
        }
    }
    
    var normalBackgroundColor = UIColor.black
    {
        didSet
        {
            backgroundColor = normalBackgroundColor
        }
    }
    
    // MARK: Animate Button Press
    
    override func pressesBegan(_ presses: Set<UIPress>,
        with event: UIPressesEvent?)
    {
        super.pressesBegan(presses, with: event)

        for item in presses
        {
            if item.type == .select || (item.type == .playPause && pressedDownByPlayPauseButton)
            {
                moveDownAnimated()
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>,
        with event: UIPressesEvent?)
    {
        super.pressesEnded(presses, with: event)

        for item in presses
        {
            if item.type == .select || (item.type == .playPause && pressedDownByPlayPauseButton)
            {
                moveUpAnimated()
            }
        }
    }
    
    override func pressesChanged(_ presses: Set<UIPress>,
        with event: UIPressesEvent?)
    {
        super.pressesChanged(presses, with: event)
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>,
        with event: UIPressesEvent?)
    {
        super.pressesCancelled(presses, with: event)
        
        for item in presses
        {
            if item.type == .select || (item.type == .playPause && pressedDownByPlayPauseButton)
            {
                moveUpAnimated()
            }
        }
    }
    
    var pressedDownByPlayPauseButton = false
}
