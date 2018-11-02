//
//  VideoDescriptionView.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 28/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit

class VideoDescriptionView: FocusableView
{
    // MARK: Life Cycle
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)

        normalBackgroundColor = UIColor.LondonRealBackground()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Describe Video
    
    func describeVideo(_ video: Video)
    {
        videoTitleLabel.text = video.title
        descriptionLabel.text = video.description
        descriptionTextView.text = video.description
    }
    
    var videoTitle: String?
    {
        get
        {
            return videoTitleLabel.text
        }
    }
    
    // MARK: Layout
    
    func layoutForRegularSize()
    {
        removeAnimatedConstraints()
        
        // title
        animatedConstraints.append(videoTitleLabel.autoPinEdge(toSuperviewEdge: .top,
            withInset: 30))
        
        animatedConstraints.append(videoTitleLabel.autoPinEdge(toSuperviewEdge: .left,
            withInset: 20))

        // description label
        var insets = UIEdgeInsetsMake(100, 20, 20, 20)
        animatedConstraints += descriptionLabel.autoPinEdgesToSuperviewEdges(with: insets)
        descriptionLabel.alpha = 1
        
        // description text view
        insets = UIEdgeInsetsMake(100, 20, 20, 20)
        animatedConstraints += descriptionTextView.autoPinEdgesToSuperviewEdges(with: insets)
        descriptionTextView.alpha = 0
    }
    
    func layoutForFullscreen()
    {
        removeAnimatedConstraints()
        
        let sidePadding: CGFloat = 400
        
        // title
        animatedConstraints.append(videoTitleLabel.autoPinEdge(toSuperviewEdge: .top,
            withInset: LondonRealStyle.screenPaddingCGFloat))
        
        animatedConstraints.append(videoTitleLabel.autoPinEdge(toSuperviewEdge: .left,
            withInset: sidePadding))

        // description label
        var insets = UIEdgeInsetsMake(150,
            sidePadding,
            LondonRealStyle.screenPaddingCGFloat,
            sidePadding)
        animatedConstraints += descriptionLabel.autoPinEdgesToSuperviewEdges(with: insets)
        descriptionLabel.alpha = 0
        
        // description text view
        insets = UIEdgeInsetsMake(150,
            sidePadding,
            LondonRealStyle.screenPaddingCGFloat,
            sidePadding)
        animatedConstraints += descriptionTextView.autoPinEdgesToSuperviewEdges(with: insets)
        descriptionTextView.alpha = 1
    }
    
    fileprivate func removeAnimatedConstraints()
    {
        removeConstraints(animatedConstraints)
        animatedConstraints.removeAll()
    }
    
    fileprivate var animatedConstraints = [NSLayoutConstraint]()
    
    // MARK: Views
    
    fileprivate lazy var descriptionLabel: UILabel =
    {
        // create
        let label = UILabel.newAutoLayout()
        self.addSubview(label)
        
        // style
        label.font = UIFont.LondonReal()
        label.numberOfLines = 0
        label.textColor = UIColor.LondonRealUnfocusedText()
        
        return label
    }()
    
    fileprivate lazy var descriptionTextView: UITextView =
    {
        // create
        let view = UITextView.newAutoLayout()
        self.addSubview(view)
        
        // scrolling
        view.isUserInteractionEnabled = true
        view.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouchType.indirect.rawValue)]
        
        // style
        view.textContainerInset = UIEdgeInsets.zero
        view.font = UIFont.LondonRealLarge()
        view.textColor = UIColor.LondonRealUnfocusedText()
        
        return view
    }()
    
    fileprivate lazy var videoTitleLabel: UILabel =
    {
        // create
        let label = UILabel.newAutoLayout()
        self.addSubview(label)
        
        // style
        label.font = UIFont.LondonRealHeadline()
        label.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        label.setContentHuggingPriority(UILayoutPriorityRequired,
            for: UILayoutConstraintAxis.vertical)
        
        return label
    }()
}
