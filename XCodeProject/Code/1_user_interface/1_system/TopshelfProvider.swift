//
//  ServiceProvider.swift
//  LondonRealTVTopshelf
//
//  Created by Sebastian Fichtner on 17/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation
import TVServices

class TopshelfProvider: NSObject, TVTopShelfProvider
{
    // MARK: - TVTopShelfProvider protocol

    var topShelfStyle: TVTopShelfContentStyle
    {
        return .sectioned
    }
    
    var topShelfItems: [TVContentItem]
    {
        //print("ts looking for existing items")
        
        // return sections
        if let sectionItem = sectionItem
        {
            return [sectionItem]
        }
        
        // load videos
        guard let videos = WebVideoLoader().loadLatestEpisodesForTopshelf(5)
            , videos.count > 0
        else
        {
            return []
        }
        
        // create content items from videos
        var contentItems = [TVContentItem]()
        
        for i in 0 ..< videos.count
        {
            if let video = videos[i] as Video?,
                let identifierString = video.title,
                let identifier = TVContentIdentifier(identifier: identifierString,
                    container: nil),
                let item = TVContentItem(contentIdentifier: identifier),
                let imageURLString = video.imageURLString
            {
                item.imageURL = URL(string: imageURLString)
                item.imageShape = .HDTV
                item.title = video.title
                
                var displayURL: URL
                {
                    var components = URLComponents()
                    // this scheme is defined in the Info.plist of the app target
                    components.scheme = "LondonReal"
                    components.path = "Videos"
                    components.queryItems = [URLQueryItem(name: "title",
                        value: video.title)]
                    
                    return components.url!
                }
                
                item.displayURL = displayURL
                
                contentItems.append(item)
            }
        }
        
        // create section with content items
        guard
            let sectionIdentifier = TVContentIdentifier(identifier: "LatestEpisodesSection",
                container: nil)
        else
        {
            return []
        }
        
        guard
            let sectionItem = TVContentItem(contentIdentifier: sectionIdentifier)
        else
        {
            return []
        }
        
        sectionItem.title = "Latest Episodes"
        sectionItem.topShelfItems = contentItems
        
        return [sectionItem]
    }
    
    var sectionItem: TVContentItem? = nil
}
