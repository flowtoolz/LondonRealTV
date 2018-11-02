//
//  TOCTableViewCell.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 31/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit
import PureLayout

class ChapterTableViewCell: FocusableTableViewCell
{
    // MARK: Life Cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        normalBackgroundColor = UIColor.LondonRealBackground()
        backgroundColor = normalBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Animating Focus
    
    override func didUpdateFocus(in context: UIFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator)
    {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if context.nextFocusedView == self
        {
            coordinator.addCoordinatedAnimations(
                {
                    UIView.transition(with: self.descriptionLabel,
                        duration: UIView.inheritedAnimationDuration,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.descriptionLabel.textColor = UIColor.LondonRealFocusedText()
                        },
                        completion: nil)
                },
                completion:nil)
        }
        else
        {
            coordinator.addCoordinatedAnimations(
                {
                    UIView.transition(with: self.descriptionLabel,
                        duration: UIView.inheritedAnimationDuration,
                        options: .transitionCrossDissolve,
                        animations:
                        {
                            self.descriptionLabel.textColor = UIColor.LondonRealUnfocusedText()
                        },
                        completion: nil)
                },
                completion:nil)
        }
    }
    
    // Mark: Describe a Chapter
    
    func describeVideoChapter(_ chapter: VideoChapter, ofLengthInSeconds length: Int)
    {
        timeLabel.text = VideoTime(totalSeconds: length).string()
        descriptionLabel.text = chapter.description
    }
    
    lazy var descriptionLabel: UILabel =
    {
        // create
        let label = UILabel.newAutoLayout()
        self.contentView.addSubview(label)
        
        // style
        label.font = UIFont.LondonReal()
        label.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 20),
            excludingEdge: .right)
        label.autoPinEdge(.right,
            to: .left,
            of: self.timeLabel,
            withOffset: 20)
        
        return label
    }()
    
    lazy var timeLabel: UILabel =
    {
        // create
        let label = UILabel.newAutoLayout()
        self.contentView.addSubview(label)
        
        // style
        label.font = UIFont.LondonReal()
        label.textColor = UIColor.LondonRealUnfocusedText()
        label.textAlignment = .right
        
        // layout
        label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 20),
            excludingEdge: .left)
        label.autoSetDimension(.width, toSize: 90)
        
        return label
    }()
}
