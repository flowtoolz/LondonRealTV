//
//  VideoListView.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 09/11/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit

class VideoTableView: UITableView
{
    // MARK: Life Cycle
    
    override init(frame: CGRect, style: UITableViewStyle)
    {
        super.init(frame: frame, style: style)
        
        remembersLastFocusedIndexPath = true
        
        register(VideoTableViewCell.self,
            forCellReuseIdentifier:"VideoTableViewCell")
        
        listenToModelUpdates()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Video Loading
    
    func listenToModelUpdates()
    {
        let nc = NotificationCenter.default
        
        nc.addObserver(self,
            selector: #selector(VideoTableView.domainModelDidUpdateVideos(_:)),
            name: NSNotification.Name(rawValue: DomainModel.DidUpdateVideosNotification),
            object: nil)
        
        nc.addObserver(self,
            selector: #selector(VideoTableView.domainModelWillLoadVideos(_:)),
            name: NSNotification.Name(rawValue: DomainModel.WillLoadVideosNotification),
            object: nil)
    }
    
    func domainModelWillLoadVideos(_ notification: Notification)
    {
        if DomainModel.sharedInstance.videos.isEmpty
        {
            showLoadingIndicator()
        }
    }
    
    func domainModelDidUpdateVideos(_ notification: Notification)
    {
        reloadData()
        
        hideLoadingIndicator()
    }

    // MARK: Loading Indicator
    
    func showLoadingIndicator()
    {
        loadingIndicator.isHidden = false
        
        weak var weakSelf = self
        
        UIView.animate(withDuration: 1.0,
            delay: 0,
            options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat],
            animations:
            {
                weakSelf?.loadingIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            },
            completion:
            { _ in
                weakSelf?.loadingIndicator.transform = CGAffineTransform.identity
        })
    }
    
    func hideLoadingIndicator()
    {
        loadingIndicator.isHidden = true
        loadingIndicator.layer.removeAllAnimations()
    }
    
    lazy var loadingIndicator: UILabel =
    {
        // create
        let indicator = UILabel.newAutoLayout()
        self.addSubview(indicator)
        
        // style
        indicator.text = "Loading Episodes ..."
        indicator.font = UIFont.LondonReal(50)
        indicator.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        indicator.autoCenterInSuperview()
        
        return indicator
    }()
}
