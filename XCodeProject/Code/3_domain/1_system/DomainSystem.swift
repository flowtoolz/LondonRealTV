//
//  DomainSystem.swift
//  XCodeProjectIOS
//
//  Created by Sebastian Fichtner on 06/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation
import TVServices

class DomainSystem: NSObject
{
    // MARK: Singleton Access
    
    public static let sharedInstance = DomainSystem()
    
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
        DomainModel.makeSureInstanceExists()
        
        // inject video loader into model
        provideVideoLoaderToDomainModel()
    }
 
    // MARK: Provide Video Loader to Domain Model
    
    let videoLoader = WebVideoLoader()
    
    func provideVideoLoaderToDomainModel()
    {
        DomainModel.sharedInstance.videoLoader = videoLoader
    }
    
    func reloadVideos()
    {
        videoLoader.loadVideos()
    }
}
