//
//  Video.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 09/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import Foundation

class Video
{
    // content
    func createDefaultChapters()
    {
        let durationInSeconds = duration.totalSeconds()
        
        for i in 0..<20
        {
            let relativeStartTime = Float(i) / 20
            let startTimeSeconds = Int(relativeStartTime * Float(durationInSeconds))
            let startTime = VideoTime(totalSeconds: startTimeSeconds)
            
            let description = "Chapter \(i + 1) / 20   ( Real chapters coming soon )"
            
            let chapter = VideoChapter(time: startTime, description: description)
            
            chapters.append(chapter)
        }
    }
    
    func lengthOfChapterAtIndex(_ index: Int) -> Int
    {
        guard index < chapters.count else
        {
            return 0
        }
        
        var endOfChapter: Int = 0
        
        if index < chapters.count - 1
        {
            endOfChapter = chapters[index + 1].time.totalSeconds()
        }
        else
        {
            endOfChapter = duration.totalSeconds()
        }
        
        return endOfChapter - chapters[index].time.totalSeconds()
    }
    
    var title: String?
    var description: String?
    var chapters = [VideoChapter]()
    
    // statistics
    var viewCount: Int = 0
    var likes: Int = 0
    var dislikes: Int = 0
    
    // other info
    var publicationDate = Date()
    var duration = VideoTime()
    
    // technical
    var imageURLString: String?
    var smallImageURLString: String?
    var fileURLString: String?
    var youtubeID: String?
}

struct VideoChapter
{
    init (time: VideoTime, description: String)
    {
        self.time = time
        self.description = description
    }
    
    var time = VideoTime()
    var description = ""
}

struct VideoTime
{
    init(totalSeconds: Int = 0)
    {
        hours = totalSeconds / 3600
        
        let remaining = totalSeconds - hours * 3600
        
        minutes = remaining / 60
        
        seconds = remaining % 60
    }
    
    func totalSeconds() -> Int
    {
        return hours * 3600 + minutes * 60 + seconds
    }
    
    func string() -> String
    {
        var string = ""
        
        if hours > 0
        {
            string += "\(hours):"
        }
        
        string += String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        
        return string
    }
    
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
}

