//
//  ContentTableViewCell.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 08/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit
import PureLayout

class VideoTableViewCell: FocusableTableViewCell
{
    // MARK: Life Cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        normalBackgroundColor = UIColor.LondonRealBackground()
        
        // in  the init() didSet will not be triggered so we do this manually
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
                    UIView.transition(with: self.videoTitleLabel,
                        duration: UIView.inheritedAnimationDuration,
                        options: .transitionCrossDissolve,
                        animations:
                        {
                            self.videoTitleLabel.textColor = UIColor.LondonRealFocusedText()
                        },
                        completion: nil)
                },
                completion:nil)
        }
        else
        {
            coordinator.addCoordinatedAnimations(
                {
                    UIView.transition(with: self.videoTitleLabel,
                        duration: UIView.inheritedAnimationDuration,
                        options: .transitionCrossDissolve,
                        animations:
                        {
                            self.videoTitleLabel.textColor = UIColor.LondonRealUnfocusedText()
                        },
                        completion: nil)
                },
                completion:nil)
        }
    }

    // MARK: Video Infos
    
    weak var video: Video?
    {
        didSet
        {
            guard let video = self.video else
            {
                return
            }
            
            // title
            self.videoTitleLabel.text = video.title?.uppercased()
        
            // image
            if let urlString = video.smallImageURLString,
                let imageURL = URL(string: urlString)
            {
                self.videoImageView.af_setImage(withURL: imageURL,
                    placeholderImage: VideoTableViewCell.guestImagePlaceHolder)
            }
            
            // view count
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let viewCountString = numberFormatter.string(from: NSNumber(value:video.viewCount))!
            self.videoViewCountLabel.text = "  " + viewCountString
            self.viewCountIcon.setNeedsDisplay()
        }
    }
    
    static var guestImagePlaceHolder = UIImage(named: "GuestImagePlaceholder")
    
    lazy var videoTitleLabel: UILabel =
    {
        // create
        let titleLabel = UILabel.newAutoLayout()
        self.contentView.addSubview(titleLabel)
        
        // style
        titleLabel.font = UIFont.LondonRealHeadline()
        titleLabel.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        titleLabel.autoPinEdge(toSuperviewEdge: .top)
        titleLabel.autoPinEdge(toSuperviewEdge: .bottom)
        titleLabel.autoPinEdge(.left,
            to: .right,
            of: self.videoImageView,
            withOffset: 20)
        
        return titleLabel
    }()
    
    lazy var videoImageView: UIImageView =
    {
        // create
        let imageView = UIImageView.newAutoLayout()
        self.contentView.addSubview(imageView)
        
        // style
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.backgroundColor = UIColor.black
        
        // layout
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero,
            excludingEdge: .right)
        imageView.autoMatch(.width,
            to: .height,
            of:imageView,
            withMultiplier: 16.0 / 9.0)
        
        return imageView
    }()
    
    lazy var viewCountIcon: UIImageView =
    {
        // create
        let icon = UIImageView.newAutoLayout()
        icon.image = UIImage(named: "eye")
        self.contentView.addSubview(icon)
        
        // style
        icon.contentMode = .scaleAspectFit
        
        // layout
        icon.autoPinEdge(.right,
            to: .left,
            of: self.videoViewCountLabel,
            withOffset: 0)
        icon.autoPinEdge(.top,
            to: .top,
            of: self.videoViewCountLabel,
            withOffset: 7)
        
        icon.autoSetDimensions(to: CGSize(width: 35, height: 35))
        
        return icon
    }()

    lazy var videoViewCountLabel: UILabel =
    {
        // create
        let viewCountLabel = UILabel.newAutoLayout()
        self.contentView.addSubview(viewCountLabel)
        
        // style
        viewCountLabel.font = UIFont.LondonReal()
        viewCountLabel.textColor = UIColor.LondonRealUnfocusedText()
        viewCountLabel.textAlignment = .right
        
        // layout
        viewCountLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired,
            for: UILayoutConstraintAxis.horizontal)
        viewCountLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        viewCountLabel.autoConstrainAttribute(ALAttribute.horizontal,
            to: ALAttribute.horizontal,
            of: self)
        
        return viewCountLabel
    }()
}
