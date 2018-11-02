//
//  VideoLoader.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 11/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

protocol VideoLoaderDelegate: class
{
    func videoLoaderDidLoad(_ videos: [Video])
}

protocol VideoLoader: class
{
    func loadVideos()
    func loadLatestEpisodesForTopshelf(_ numberOfVideos: Int) -> [Video]?
    
    var delegate: VideoLoaderDelegate? { get set }
}
