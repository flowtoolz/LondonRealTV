//
//  DomainModel.swift
//  XCodeProjectIOS
//
//  Created by Sebastian Fichtner on 06/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation

class DomainModel: NSObject, VideoLoaderDelegate
{
    // MARK: Singleton Access

    public static let sharedInstance = DomainModel()
    
    override private init()
    {
        super.init()
        
        initialize()
    }
    
    // MARK: Initialization
    
    public static func makeSureInstanceExists()
    {
        print("making sure shared instance exists: \(sharedInstance.description)")
    }
    
    private func initialize()
    {
        
    }
    
    // MARK: Loading Videos
    
    weak var videoLoader: VideoLoader?
    {
        didSet
        {
            guard let videoLoader = self.videoLoader else
            {
                return
            }
            
            videoLoader.delegate = self
        }
    }

    func loadVideos()
    {
        guard let videoLoader = videoLoader else
        {
            return
        }

        let nc = NotificationCenter.default
        
        nc.post(name: Notification.Name(rawValue: DomainModel.WillLoadVideosNotification), object: nil)
        
        videoLoader.loadVideos()
    }
    
    static let WillLoadVideosNotification = "WillLoadVideosNotification"
    
    func unloadVideos()
    {
        videos.removeAll()
        
        let nc = NotificationCenter.default
        
        nc.post(name: Notification.Name(rawValue: DomainModel.DidUpdateVideosNotification), object: nil)
    }
    
    func videoLoaderDidLoad(_ videos: [Video])
    {
        self.videos = videos

        let nc = NotificationCenter.default
        
        nc.post(name: Notification.Name(rawValue: DomainModel.DidUpdateVideosNotification), object: nil)
    }
    
    static let DidUpdateVideosNotification = "DomainModelDidUpdateVideos"
    
    // MARK: Access Loaded Videos
    
    func getVideoIndexWithTitle(_ title: String) -> Int?
    {
        return videos.index(where: {$0.title == title})
    }
    
    func getVideoWithTitle(_ title: String) -> Video?
    {
        if let index = getVideoIndexWithTitle(title)
        {
            return videos[index]
        }
        
        return nil
    }
    
    var videos = [Video]()
}
