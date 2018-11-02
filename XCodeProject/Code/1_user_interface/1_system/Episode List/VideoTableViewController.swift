//
//  ViewController.swift
//  LondonRealTV
//
//  Created by Sebastian Fichtner on 01/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit
import AlamofireImage

class VideoTableViewController: UIViewController, UITableViewDelegate
{
    // MARK: Life Cycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.title = "Episodes"
        
        let nc = NotificationCenter.default
    
        nc.addObserver(self,
                       selector: #selector(VideoTableViewController.domainModelDidUpdateVideos(_:)),
                       name: NSNotification.Name(rawValue: DomainModel.DidUpdateVideosNotification),
                       object: nil)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // style
        view.backgroundColor = UIColor.LondonRealBackground()
        
        // show views
        tableView.setNeedsDisplay()
        //academyView.canBecomeFocused()
        //feedbackView.canBecomeFocused()
        
        // connect play/pause button
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(VideoTableViewController.playPausePressed(_:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)];
        view.addGestureRecognizer(tapRecognizer)

        listenToWebLoadingFailures()
    }
    
    // MARK: Play Video From Topshelf
    
    func domainModelDidUpdateVideos(_ notification: Notification)
    {
        if let title = titleOfVideoToPlayAfterNextVideoReload
        {
            playVideoWithTitle(title)
        }
        
        titleOfVideoToPlayAfterNextVideoReload = nil
    }
    
    var titleOfVideoToPlayAfterNextVideoReload: String? = nil
    
    // MARK: Table View

    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 180.0
    }
    
    lazy var tableView: VideoTableView =
    {
        // create
        let tableView = VideoTableView.newAutoLayout()
        self.view.addSubview(tableView)

        // connect
        tableView.delegate = self
        tableView.dataSource = self.tableViewDataSource
        
        // layout
        var insets = UIEdgeInsets(inset: LondonRealStyle.screenPaddingCGFloat)
        tableView.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: .right)
        tableView.autoSetDimension(.width, toSize: 1350)
        
        return tableView
    }()
    
    let tableViewDataSource = VideoTableViewDataSource()
    
    // MARK: Focus & Interaction
    
    override var preferredFocusedView: UIView?
    {
        get
        {
            if let index = lastFocusedEpisodeIndex
            {
                return tableView.cellForRow(at: IndexPath(row: index,
                    section: 0))
            }
            
            return tableView
        }
    }
    
    var lastFocusedEpisodeIndex: Int?
    
    func tableView(_ tableView: UITableView,
        didUpdateFocusIn context: UITableViewFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator)
    {
        self.view.bringSubview(toFront: self.tableView)
        
        guard let indexPath = context.nextFocusedIndexPath else
        {
            return
        }
        
        lastFocusedEpisodeIndex = (indexPath as NSIndexPath).row
    
        updateDescriptionForVideoAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        openVideoForIndex((indexPath as NSIndexPath).row, startPlaying: false)
    }
    
    func playPausePressed(_ sender: UITapGestureRecognizer)
    {
        guard sender.state == .ended else
        {
            return
        }

        // play selected video from list
        guard let lastFocusedEpisodeIndex = lastFocusedEpisodeIndex else
        {
            return
        }
        
        openVideoForIndex(lastFocusedEpisodeIndex, startPlaying: true)
    }
    
    // MARK: Open & Play Videos
    
    func playVideoWithTitle(_ title: String)
    {
        let model = DomainModel.sharedInstance
        
        if let index = model.getVideoIndexWithTitle(title)
        {
            lastFocusedEpisodeIndex = index
            openVideoForIndex(index, startPlaying: true)
        }
        else
        {
            //print("could not find video with title: " + title)
            titleOfVideoToPlayAfterNextVideoReload = title
        }
    }
    
    func openVideoForIndex(_ index: Int, startPlaying: Bool)
    {
        let model = DomainModel.sharedInstance
        
        let vvc = VideoViewController()
        
        vvc.video = model.videos[index]
        vvc.startPlayingWhenViewAppears = startPlaying
        
        present(vvc, animated: false, completion: nil)
    }
    
    // MARK: Video Description
    
    func updateDescriptionForVideoAtIndexPath(_ indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow(at: indexPath) as? VideoTableViewCell,
            let video = cell.video
        {
            descriptionView.text = video.description
        }
    }
    
    lazy var descriptionView: UILabel =
    {
        // create
        let view = UILabel.newAutoLayout()
        self.view.addSubview(view)
        
        // style
        view.numberOfLines = 0
        view.font = UIFont.LondonRealLarge()
        view.textColor = UIColor.LondonRealUnfocusedText()
        
        // layout
        let insets = UIEdgeInsets(inset: LondonRealStyle.screenPaddingCGFloat)
        view.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: .left)
        view.autoSetDimension(.width, toSize: 450)
        
        return view
    }()
    
    // MARK: Error Alert
    
    func listenToWebLoadingFailures()
    {
        NotificationCenter.default.addObserver(self,
            selector: #selector(VideoTableViewController.webRequestFailed(_:)),
            name: NSNotification.Name(rawValue: WebVideoLoader.RequestFailedNotification),
            object: nil)
    }
    
    func webRequestFailed(_ notification: Notification)
    {
        showError()
    }
    
    func showError()
    {
        let alertController = UIAlertController(title: "No Internet Access",
            message: "Please make sure your Apple TV is connected to the internet.",
            preferredStyle: .alert)
        
        weak var weakSelf = self
        
        let acceptAction = UIAlertAction(title: "Try Again", style: .default)
            { _ in
                weakSelf?.tableView.showLoadingIndicator()
                DomainSystem.sharedInstance.reloadVideos()
        }
        alertController.addAction(acceptAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
