//
//  VideoViewController.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 09/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController : UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // style
        view.backgroundColor = UIColor.LondonRealBackground()
        
        // listen to model updates
        let nc = NotificationCenter.default
        
        nc.addObserver(self,
            selector: #selector(VideoViewController.domainModelDidUpdateVideos(_:)),
            name: NSNotification.Name(rawValue: DomainModel.DidUpdateVideosNotification),
            object: nil)
        
        // interaction
        addGestureRecognizers()
        
        // video
        if let video = video
        {
            descriptionView.describeVideo(video)
            
            // view count
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            if let viewCountString = numberFormatter.string(from: NSNumber(value: video.viewCount))
            {
                viewCountLabel.text = "  " + viewCountString
            }

            // likes & dislikes
            if (video.likes + video.dislikes >= 10)
            {
                let likesInPercent = Int(100.0 * Float(video.likes) / Float(video.likes + video.dislikes))
                likesLabel.text = "♡  " + String(likesInPercent) + "%"
            }
            
            // publication date & duration
            publicationDateLabel.text = video.publicationDate.stringWithFormat(format: "MMMM dd, yyyy")
            durationLabel.text = video.duration.string()
            
            // give video to player view
            playerView.video = video
        }
        
        viewCountIcon.setNeedsDisplay()
        
        // layout
        positionPlayerViewWithRegularSize()
        layoutDescriptionViewInRegularSize()
        
        // test
        tableView.setNeedsDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if startPlayingWhenViewAppears
        {
            playerView.playAtSecond(0)
        }
    }
    
    var startPlayingWhenViewAppears = false
    
    // MARK: Videos Did Update
    
    func domainModelDidUpdateVideos(_ notification: Notification)
    {
        // find updated version of my video in the model by its title
        if let title = self.descriptionView.videoTitle,
            let updatedVideo = DomainModel.sharedInstance.getVideoWithTitle(title)
        {
            video = updatedVideo
        }
    }
    
    // MARK: Interaction
    
    func addGestureRecognizers()
    {
        // connect swipe left gesture to wind forward
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(VideoViewController.swipedLeft(_:)))
        swipeLeftRecognizer.direction = .left
        view.addGestureRecognizer(swipeLeftRecognizer)
        
        // connect swipe right gesture to wind backward
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(VideoViewController.swipedRight(_:)))
        swipeRightRecognizer.direction = .right
        view.addGestureRecognizer(swipeRightRecognizer)
        
        // connect play/pause button
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoViewController.playPausePressed(_:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)];
        view.addGestureRecognizer(tapRecognizer)
        
        // connect menu button
        let menuRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoViewController.menuPressed(_:)))
        menuRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)];
        view.addGestureRecognizer(menuRecognizer)
    }
    
    func swipedLeft(_ sender: UISwipeGestureRecognizer)
    {
        guard sender.state == .ended else
        {
            return
        }
        
        if playerView.isFullscreen()
        {
            playerView.windForward()
        }
    }
    
    func swipedRight(_ sender: UISwipeGestureRecognizer)
    {
        guard sender.state == .ended else
        {
            return
        }
        
        if playerView.isFullscreen()
        {
            playerView.windBackward()
        }
    }
    
    func playPausePressed(_ sender: UITapGestureRecognizer)
    {
        guard sender.state == .ended else
        {
            return
        }
        
        playerView.playOrPause()
        
        if !playerView.isFullscreen()
        {
            if playerView.isPlaying()
            {
                durationLabel.alpha = 0
            }
            else
            {
                durationLabel.alpha = 1
            }
        }
    }
    
    func menuPressed(_ sender: UITapGestureRecognizer)
    {
        guard sender.state == .ended else
        {
            return
        }
        
        playerView.pause()
        
        presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: Player View Overlays
    
    lazy var durationLabel: UILabel =
    {
        // create
        let label = UILabel.newAutoLayout()
        self.playerView.addSubview(label)
        
        // style
        label.font = UIFont.LondonReal()
        label.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        label.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        return label
    }()
    
    // MARK: Player View
    
    func playerViewPressed(_ sender: AnyObject?)
    {
        layoutPlayerViewAnimated(toFullscreen: !playerView.isFullscreen())
    }

    func layoutPlayerViewAnimated(toFullscreen fullscreen: Bool)
    {
        view.bringSubview(toFront: playerView)
        view.layoutIfNeeded()
        
        if fullscreen
        {
            layoutPlayerViewInFullscreen()
        }
        else
        {
            positionPlayerViewWithRegularSize()
        }
        
        let layoutUpdateAnimation: () -> Void =
        {
            if fullscreen
            {
                self.playerView.setScaleNormal()
                self.durationLabel.alpha = 0.0
            }
            else if !self.playerView.isPlaying()
            {
                self.playerView.setScaleElevated()
                self.durationLabel.alpha = 1.0
            }
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3,
            animations: layoutUpdateAnimation,
            completion:nil)
    }
    
    func layoutPlayerViewInFullscreen()
    {
        removeAnimatedPlayerViewConstraints()
        animatedPlayerViewConstraints += playerView.autoPinEdgesToSuperviewEdges()
    }
    
    func layoutPlayerViewInRegularSize()
    {
        positionPlayerViewWithRegularSize()
    }

    func positionPlayerViewWithRegularSize()
    {
        removeAnimatedPlayerViewConstraints()
        
        animatedPlayerViewConstraints.append(playerView.autoPinEdge(toSuperviewEdge: .left,
            withInset: LondonRealStyle.screenPaddingCGFloat))
        animatedPlayerViewConstraints.append(playerView.autoPinEdge(toSuperviewEdge: .top,
            withInset: LondonRealStyle.screenPaddingCGFloat))
        
        let widthConstraint = playerView.autoConstrainAttribute(.width,
            to: .width,
            of: view,
            withMultiplier: 0.5)
        animatedPlayerViewConstraints.append(widthConstraint)
        
        let heightConstraint = playerView.autoConstrainAttribute(.height,
            to: .height,
            of: view,
            withMultiplier: 0.5)
        animatedPlayerViewConstraints.append(heightConstraint)
    }
    
    func removeAnimatedPlayerViewConstraints()
    {
        view.removeConstraints(animatedPlayerViewConstraints)
        animatedPlayerViewConstraints.removeAll()
    }
    
    lazy var playerView: VideoPlayerView =
    {
        // create
        let view = VideoPlayerView.newAutoLayout()
        self.view.addSubview(view)
        
        // connect
        view.addTarget(self,
            action:#selector(VideoViewController.playerViewPressed(_:)),
            for: .primaryActionTriggered)
        
        return view
    }()
    
    var animatedPlayerViewConstraints = [NSLayoutConstraint]()
    
    // MARK: Statistics
    
    lazy var viewCountLabel: UILabel =
    {
        // create
        let label = UILabel.newAutoLayout()
        self.view.addSubview(label)
        
        // style
        label.font = UIFont.LondonReal()
        label.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        let screenWidth = UIScreen.main.bounds.size.width
        let right = screenWidth / 2 + LondonRealStyle.screenPaddingCGFloat - 20
        label.autoConstrainAttribute(.right,
            to: .right,
            of: self.view,
            withMultiplier: right / screenWidth)
        label.autoPinEdge(toSuperviewEdge: .top, withInset: self.videoInfosTopOffset)
        
        return label
    }()
    
    lazy var viewCountIcon: UIImageView =
    {
        // create
        let icon = UIImageView.newAutoLayout()
        icon.image = UIImage(named: "eye")
        self.view.addSubview(icon)
        
        // style
        icon.contentMode = .scaleAspectFit
        
        // layout
        icon.autoPinEdge(.right,
            to: .left,
            of: self.viewCountLabel,
            withOffset: 0)
        
        icon.autoPinEdge(.top,
            to: .top,
            of: self.viewCountLabel,
            withOffset: 7)
        
        icon.autoSetDimensions(to: CGSize(width: 35, height: 35))
        
        return icon
    }()
    
    lazy var likesLabel: UILabel =
    {
        // create
        let label = UILabel.newAutoLayout()
        self.view.addSubview(label)
        
        // style
        label.font = UIFont.LondonReal()
        label.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        label.autoPinEdge(.right,
            to: .left,
            of: self.viewCountLabel,
            withOffset: -80)
        label.autoPinEdge(toSuperviewEdge: .top, withInset: self.videoInfosTopOffset)
        
        return label
    }()
    
    lazy var publicationDateLabel: UILabel =
    {
        // create
        let label = UILabel.newAutoLayout()
        self.view.addSubview(label)
        
        // style
        label.font = UIFont.LondonReal()
        label.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        label.autoPinEdge(toSuperviewEdge: .left,
            withInset: LondonRealStyle.screenPaddingCGFloat + 20)
        label.autoPinEdge(toSuperviewEdge: .top, withInset: self.videoInfosTopOffset)
        
        return label
    }()
    
    let videoInfosTopOffset: CGFloat = 600
    
    // MARK: Description
    
    func descriptionViewPressed(_ sender: AnyObject?)
    {
        layoutDescriptionViewAnimated(toFullscreen: !descriptionView.isFullscreen())
    }
    
    func layoutDescriptionViewAnimated(toFullscreen fullscreen: Bool)
    {
        view.bringSubview(toFront: descriptionView)
        view.layoutIfNeeded()

        if fullscreen
        {
            layoutDescriptionViewInFullscreen()
        }
        else
        {
            layoutDescriptionViewInRegularSize()
        }

        let layoutUpdateAnimation: () -> Void =
        {
            if fullscreen
            {
                self.descriptionView.setScaleNormal()
                self.descriptionView.backgroundColor = UIColor.LondonRealBackground().withOpacity(0.8)
            }
            else
            {
                self.descriptionView.setScaleElevated()
                self.descriptionView.backgroundColor = UIColor.LondonRealBackground().brighter(1.2)
            }
            
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3,
            animations: layoutUpdateAnimation,
            completion: nil)
    }
    
    func layoutDescriptionViewInRegularSize()
    {
        positionDescriptionViewWithRegularSize()
        
        descriptionView.layoutForRegularSize()
    }
    
    func layoutDescriptionViewInFullscreen()
    {
        positionDescriptionViewWithFullscreen()
        
        descriptionView.layoutForFullscreen()
    }
    
    func positionDescriptionViewWithRegularSize()
    {
        removeAnimatedDescriptionViewConstraints()
        
        let leftConstraint = descriptionView.autoPinEdge(toSuperviewEdge: .left,
            withInset: LondonRealStyle.screenPaddingCGFloat)
        animatedDescriptionViewConstraints.append(leftConstraint)
        
        let topConstraint = descriptionView.autoPinEdge(toSuperviewEdge: .top,
            withInset: 680)
        animatedDescriptionViewConstraints.append(topConstraint)
        
        let widthConstraint = descriptionView.autoConstrainAttribute(.width,
            to: .width,
            of: view,
            withMultiplier: 0.5)
        animatedDescriptionViewConstraints.append(widthConstraint)
        
        let bottomConstraint = descriptionView.autoPinEdge(toSuperviewEdge: .bottom,
            withInset: LondonRealStyle.screenPaddingCGFloat)
        animatedDescriptionViewConstraints.append(bottomConstraint)
    }
    
    func positionDescriptionViewWithFullscreen()
    {
        removeAnimatedDescriptionViewConstraints()
        
        animatedDescriptionViewConstraints += descriptionView.autoPinEdgesToSuperviewEdges()
    }
    
    fileprivate func removeAnimatedDescriptionViewConstraints()
    {
        view.removeConstraints(animatedDescriptionViewConstraints)
        animatedDescriptionViewConstraints.removeAll()
    }
    
    lazy var descriptionView: VideoDescriptionView =
    {
        // create
        let description = VideoDescriptionView.newAutoLayout()
        self.view.addSubview(description)
        
        // connect
        description.addTarget(self,
            action:#selector(VideoViewController.descriptionViewPressed(_:)),
            for: .primaryActionTriggered)
        
        return description
    }()
    
    var animatedDescriptionViewConstraints = [NSLayoutConstraint]()
    
    // MARK: Table of Contents
    
    func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let video = video else
        {
            return
        }
        
        durationLabel.alpha = 0
        
        let time = video.chapters[(indexPath as NSIndexPath).row].time
        
        playerView.playAtSecond(time.totalSeconds())
    }
    
    func tableView(_ tableView: UITableView,
        didUpdateFocusIn context: UITableViewFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator)
    {
        view.bringSubview(toFront: tableView)
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int
    {
        guard let video = video else
        {
            return 0
        }
        
        return video.chapters.count
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterTableViewCell",
            for: indexPath) as? ChapterTableViewCell
        else
        {
            //print("could not create ChapterTableViewCell")
            return UITableViewCell()
        }
        
        if let video = video
        {
            cell.describeVideoChapter(video.chapters[(indexPath as NSIndexPath).row],
                ofLengthInSeconds: video.lengthOfChapterAtIndex((indexPath as NSIndexPath).row))
        }
        else
        {
            //print("could not get video while configuring ChapterTableViewCell")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90.0
    }
    
    lazy var tableView: UITableView =
    {
        // create
        let tableView = UITableView.newAutoLayout()
        self.view.addSubview(tableView)
        
        // style
        tableView.remembersLastFocusedIndexPath = true
        
        // connect
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChapterTableViewCell.self,
            forCellReuseIdentifier:"ChapterTableViewCell")
        
        // layout
        tableView.autoSetDimension(.width, toSize: 840)
        var insets = UIEdgeInsets(inset: LondonRealStyle.screenPaddingCGFloat)
        tableView.autoPinEdgesToSuperviewEdges(with: insets,
            excludingEdge: .left)
        
        return tableView
    }()
    
    // MARK: Video
    
    weak var video: Video?
}
