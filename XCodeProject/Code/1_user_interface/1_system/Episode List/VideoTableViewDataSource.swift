//
//  VideoTableViewDataSource.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 09/11/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit

class VideoTableViewDataSource: NSObject, UITableViewDataSource
{
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // create cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell",
            for: indexPath) as? VideoTableViewCell
            else
        {
            return UITableViewCell()
        }
        
        // configure cell
        cell.pressedDownByPlayPauseButton = true
        
        // set video
        let model = DomainModel.sharedInstance
        cell.video = model.videos[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        let model = DomainModel.sharedInstance
        return model.videos.count
    }
}
