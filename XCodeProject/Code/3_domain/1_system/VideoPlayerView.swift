//
//  VideoPlayerView.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 23/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: FocusableView
{
    // MARK: Life Cycle
    
    override init(frame: CGRect)
    {
        //print("init video player view")
        super.init(frame: frame)
        
        // animate play presses
        pressedDownByPlayPauseButton = true
        
        // create player layer before any subviews are added so that it is always behind subviews
        playerLayer.frame.size = frame.size
        
        // observe when player plays from the beginning
        observeWhenPlayingStarts()
        
        // observe the player playing/pausing
        self.player.addObserver(self,
            forKeyPath: "rate",
            options: NSKeyValueObservingOptions.old,
            context: nil)
        
        // make sure playbutton is on top of curtain image
        curtainImageView.setNeedsDisplay()
        playSymbolImageView.setNeedsDisplay()
    }
    
    deinit
    {
        self.player.currentItem?.removeObserver(self,
                                               forKeyPath: "status",
                                               context: nil)
        
        self.player.removeObserver(self,
                                   forKeyPath: "rate",
                                   context: nil)
        
        if let timeObserver = timeObserver
        {
            player.removeTimeObserver(timeObserver)
        }
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        updatePlayerLayerFrameAnimated()
    }
    
    // MARK: Control Playback
    
    func playAtSecond(_ startTime: Int)
    {
        playingStartTime = Double(startTime)
        
        if player.currentItem?.status != AVPlayerItemStatus.readyToPlay
        {
            hideLoadingIndicator()
            showPreloadingIndicator()
            seekToStartTimeAndPlayWhenPlayerItemBecomesReady = true
            //print("streaming debugging: showing preloading indicator because player item not ready")
            
            return
        }
        
        showLoadingIndicator()

        seekToStartTimeAndStartPlaying()
    }
    
    var seekToStartTimeAndPlayWhenPlayerItemBecomesReady = false
    
    func seekToStartTimeAndStartPlaying()
    {
        player.pause()
        
        player.seek(to: CMTimeMake(Int64(playingStartTime), 1),
                    toleranceBefore: CMTimeMake(1, 1),
                    toleranceAfter: CMTimeMake(1, 100))
        {
            (finished: Bool) -> Void in
            
            if !finished
            {
                return
            }
            
            //print("player did seek to time \(self.player.currentTime().seconds)")
            
            self.play()
        }
    }
    
    func playOrPause()
    {
        if isPlaying()
        {
            pause()
        }
        else
        {
            play()
        }
    }
    
    func isPlaying() -> Bool
    {
        return player.rate > 0
    }
    
    func play()
    {
        guard player.error == nil &&
            player.currentItem?.status == AVPlayerItemStatus.readyToPlay
        else
        {
            return
        }
        
        if playingStartTime == 0
        {
            showLoadingIndicator()
        }
    
        playSymbolImageView.isHidden = true
        curtainImageView.isHidden = true
        hidePreloadingIndicator()
        
        player.play()
    }
    
    func pause()
    {
        playSymbolImageView.isHidden = false
        curtainImageView.isHidden = player.currentTime().seconds >= 0.1
        hideLoadingIndicator()
        
        player.pause()
    }
    
    func windForward()
    {
        guard player.status == .readyToPlay else
        {
            return
        }
        
        // wind forward
        let windForwardSeconds: Int64 = 30
        player.seek(to: CMTimeAdd(player.currentTime(), CMTimeMake(windForwardSeconds, 1)))
    }
    
    func windBackward()
    {
        guard player.status == .readyToPlay else
        {
            return
        }
        
        // wind backward
        let windBackwardSeconds: Int64 = 30
        player.seek(to: CMTimeSubtract(player.currentTime(), CMTimeMake(windBackwardSeconds, 1)))
    }
    
    // Observe Playing
    
    func playerItemDidPlayToEnd(_ notification: Notification)
    {
        curtainImageView.isHidden = false
        playSymbolImageView.isHidden = false
        
        player.seek(to: CMTimeMake(0, 1))
    }
    
    func playerItemDidJump(_ notification: Notification)
    {
        //print("player item did jump to second \(player.currentItem?.currentTime().seconds)")
    }
    
    func playerItemDidStall(_ notification: Notification)
    {
        //print("player item did stall at second \(player.currentItem?.currentTime().seconds)")
        
        playerPausedByItself()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        if keyPath == "rate" // player rate
        {
            if isPlaying()
            {
                //print("hiding loading indicator cause player rate increased")
                hideLoadingIndicator()
            }
        }
        else if keyPath == "status" // player item status
        {
            if let changeDic = change as? [NSKeyValueChangeKey : Int],
                let oldStatusInt = changeDic[NSKeyValueChangeKey.oldKey],
                let newStatusInt = changeDic[NSKeyValueChangeKey.newKey],
                let oldStatus = AVPlayerItemStatus(rawValue: oldStatusInt),
                let newStatus = AVPlayerItemStatus(rawValue: newStatusInt)
            {
                //print("streaming debugging: player item status changed from \(stringFromAVPlayerItemStatus(status: oldStatus)) to \(stringFromAVPlayerItemStatus(status: newStatus))")
                
                if oldStatus != .readyToPlay && newStatus == .readyToPlay
                {
                    if seekToStartTimeAndPlayWhenPlayerItemBecomesReady
                    {
                        //print("streaming debugging: seek to start time and play now that player item is ready")
                        seekToStartTimeAndStartPlaying()
                        
                        seekToStartTimeAndPlayWhenPlayerItemBecomesReady = false
                    }
                }
            }
        }
    }
    
    func stringFromAVPlayerItemStatus(status: AVPlayerItemStatus) -> String
    {
        switch status
        {
            case AVPlayerItemStatus.unknown: return "unknown"
            
            case AVPlayerItemStatus.readyToPlay: return "readyToPlay"
            
            case AVPlayerItemStatus.failed: return "failed"
        }
    }
    
    
    func playerPausedByItself()
    {
        //print("hiding loading indicator cause player paused by itself")
        
        hideLoadingIndicator()
        
        guard let video = video else
        {
            return
        }
        
        let closeToEnd = player.currentTime().seconds > Double(video.duration.totalSeconds()) - 1
        
        if playSymbolImageView.isHidden && !closeToEnd
        {
            // if user has not already paused: inform him that system had to pause
            playSymbolImageView.isHidden = false
            showPreloadingIndicator()
        }
    }
    
    // MARK: Observe When Playing Starts
    
    var playingStartTime: Double = 0
    {
        didSet
        {
            observeWhenPlayingStarts()
        }
    }
    
    func observeWhenPlayingStarts()
    {
        // remove old observer
        if let timeObserver = timeObserver
        {
            player.removeTimeObserver(timeObserver)
        }
        
        // add new observer
        numberOfTimersFired = 0
        
        let time0 = CMTimeMake(Int64(10 * playingStartTime) + 1, 10)
        let time1 = CMTimeMake(Int64(playingStartTime) + 1, 1)
        let time2 = CMTimeMake(Int64(playingStartTime) + 2, 1)
        let time3 = CMTimeMake(Int64(playingStartTime) + 3, 1)
        let time4 = CMTimeMake(Int64(playingStartTime) + 4, 1)
        let time5 = CMTimeMake(Int64(playingStartTime) + 5, 1)
        
        let times = [NSValue(time: time0),
                     NSValue(time: time1),
                     NSValue(time: time2),
                     NSValue(time: time3),
                     NSValue(time: time4),
                     NSValue(time: time5)]
        
        //print("adding time observer for second \(time1.seconds)")
        //print("current time \(player.currentItem?.currentTime().seconds)")
        
        timeObserver = player.addBoundaryTimeObserver(forTimes: times,
            queue: nil,
            using:
            {
                [weak self] in
                
                //print("timer \((self?.numberOfTimersFired)! + 1) fired")

                if (self?.numberOfTimersFired == 0)
                {
                    self?.startedPlaying()
                }
                
                self?.numberOfTimersFired += 1
            }
        )
    }
    
    var timeObserver: Any?
    var numberOfTimersFired = 0
    
    func startedPlaying()
    {
        //print("hiding loading indicator cause playing started")
        hideLoadingIndicator()
    }
    
    // MARK: Curtain Image View
    
    lazy var curtainImageView: UIImageView =
    {
        // create
        let view = UIImageView.newAutoLayout()
        self.addSubview(view)
        
        // style
        view.clipsToBounds = true
        view.contentMode = UIViewContentMode.scaleAspectFill
        
        // layout
        view.autoPinEdgesToSuperviewEdges()
        
        return view
    }()
    
    // MARK: Play Symbol
    
    lazy var playSymbolImageView: UIImageView =
    {
        // create
        let view = UIImageView.newAutoLayout()
        self.addSubview(view)
        
        // style
        view.image = UIImage(named: "play_button")
        view.alpha = 0.33
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 8
        
        // layout
        let screenHeight = UIScreen.main.bounds.size.height
        var heightMultiplier = 298.0 / screenHeight
        
        if let image = view.image
        {
            heightMultiplier = image.size.height / screenHeight
        }
        
        view.autoCenterInSuperview()
        view.autoConstrainAttribute(.height,
            to: .height,
            of: self,
            withMultiplier: heightMultiplier)
        view.autoConstrainAttribute(.width,
            to: .height,
            of: view)
        
        return view
    }()
    
    // MARK: Preloading Indicator
    
    func showPreloadingIndicator()
    {
        preloadingIndicator.isHidden = false
        
        UIView.animate(withDuration: 1.0,
            delay: 0,
            options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat],
            animations:
            {
                [weak self] in
                
                self?.preloadingIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            },
            completion:
            {
                [weak self] (finished: Bool) in
                
                self?.preloadingIndicator.transform = CGAffineTransform.identity
            })
    }
    
    func hidePreloadingIndicator()
    {
        preloadingIndicator.isHidden = true
        preloadingIndicator.layer.removeAllAnimations()
    }
    
    lazy var preloadingIndicator: UILabel =
    {
        // create
        let indicator = UILabel.newAutoLayout()
        self.addSubview(indicator)
        
        // style
        indicator.font = UIFont.LondonReal(50)
        indicator.textColor = UIColor.LondonRealUnfocusedText()
        indicator.text = "Paused to load video data"
        indicator.isHidden = true
        
        // layout
        indicator.autoConstrainAttribute(.vertical,
            to: .vertical,
            of: self)
        indicator.autoPinEdge(.top,
            to: .bottom,
            of: self.playSymbolImageView,
            withOffset: 20)
        
        return indicator
    }()
    
    // MARK: Loading Indicator
    
    func showLoadingIndicator()
    {
        hidePreloadingIndicator()
        playSymbolImageView.isHidden = true
        loadingIndicator.isHidden = false
        
        UIView.animate(withDuration: 1.0,
            delay: 0,
            options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat],
            animations:
            {
                [weak self] in
                
                self?.loadingIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            },
            completion:
            {
                [weak self] (finished: Bool) in

                self?.loadingIndicator.transform = CGAffineTransform.identity
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
        indicator.font = UIFont.LondonReal(50)
        indicator.textColor = UIColor.LondonRealUnfocusedText()
        indicator.text = "Loading Video ..."
        
        // layout
        indicator.autoCenterInSuperview()
        
        return indicator
    }()
    
    // MARK: Video
    
    weak var video: Video?
    {
        didSet
        {
            guard let video = video,
                let videoURLString = video.fileURLString else
            {
                return
            }
            
            // update asset
            let asset = AVAsset(url: URL(string: videoURLString)!)
            
            // update player item
            let playerItem = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: playerItem)
            
            // listen to player item
            let nc = NotificationCenter.default
            
            nc.addObserver(self,
                selector: #selector(VideoPlayerView.playerItemDidPlayToEnd(_:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: playerItem)
            
            nc.addObserver(self,
                selector: #selector(VideoPlayerView.playerItemDidJump(_:)),
                name: NSNotification.Name.AVPlayerItemTimeJumped,
                object: playerItem)

            nc.addObserver(self,
                selector: #selector(VideoPlayerView.playerItemDidStall(_:)),
                name: NSNotification.Name.AVPlayerItemPlaybackStalled,
                object: playerItem)
            
            playerItem.addObserver(self,
                                   forKeyPath: "status",
                                   options: NSKeyValueObservingOptions([.new, .old]),
                                   context: nil)
            
            // curtain image
            if let imageUrlString = video.imageURLString,
                let imageUrl = URL(string: imageUrlString)
            {
                curtainImageView.af_setImage(withURL: imageUrl)
            }
        }
    }
    
    fileprivate func updatePlayerLayerFrameAnimated()
    {
        CATransaction.begin()
        CATransaction.setAnimationDuration(CFTimeInterval(0.3))
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        playerLayer.frame.size = bounds.size
        if isFullscreen()
        {
            playSymbolImageView.layer.shadowRadius = 8
        }
        else
        {
            playSymbolImageView.layer.shadowRadius = 4
        }
        CATransaction.commit()
    }
    
    lazy var playerLayer: AVPlayerLayer =
    {
        let layer = AVPlayerLayer(player: self.player)
        self.layer.addSublayer(layer)
        
        return layer
    }()
    
    var player = AVPlayer()
}
