//
//  WebVideoLoader.swift
//  XCodeProjectTVOS
//
//  Created by Sebastian Fichtner on 11/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import AVFoundation
import Alamofire
import Flowtoolz

class WebVideoLoader: VideoLoader
{
    var delegate: VideoLoaderDelegate?
    
    // MARK: Topshelf
    
    func loadLatestEpisodesForTopshelf(_ numberOfVideos: Int) -> [Video]?
    {
        loadingSynchronously = true
        numberOfVideosToLoad = numberOfVideos
    
        // enter dispatch group
        synchronousLoadingDispatchGroup = DispatchGroup()
        
        guard let dispatchGroup = synchronousLoadingDispatchGroup else
        {
            return []
        }
        
        dispatchGroup.enter()
        
        // load
        prepareVideoLoading()
        vimeoEpisodes.removeAll()
        loadLatestEpisodesFromVimeoAlbum()
        
        // wait for thread to leave dispatch group
        _ = dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        synchronousLoadingDispatchGroup = nil
        loadingSynchronously = false
        
        // return results
        sortResults()
        
        return resultsArray
    }
    
    var synchronousLoadingDispatchGroup: DispatchGroup?
    var loadingSynchronously = false
    var numberOfVideosToLoad = 100
    
    // MARK: Start Loading Process
    
    func loadVideos()
    {
        prepareVideoLoading()
        
        loadVimeoVideos()
        
        // YOUTUBE
        youtubeStatisticsById.removeAll()
        youtubeStatisticsByTitle.removeAll()
        addAcademyTourYoutubeVideo()
        loadLatestEpisodesFromYoutubePlaylist()
    }
    
    func prepareVideoLoading()
    {
        loadingFailed = false
        vimeoAcademyTourLoaded = false
        vimeoEpisodesLoaded = false
        vimeoVideosLoaded = false
        youtubeStatisticsLoaded = false
    }
    
    func loadVimeoVideos()
    {
        vimeoEpisodes.removeAll()
        loadAcademyTourFromVimeo()
        loadLatestEpisodesFromVimeoAlbum()
    }
    
    // MARK: Create Videos From Vimeo Album
    
    func loadLatestEpisodesFromVimeoAlbum()
    {
        guard let vimeoRequest = vimeoRequestForLatestEpisodes(numberOfVideosToLoad) else
        {
            return
        }
        
        vimeoRequest.responseJSON
            {
                response in
        
                self.videosFromVimeoAlbumVideosJSONResponse(response)
            }
    }
    
    func vimeoRequestForLatestEpisodes(_ numberOfVideos: Int = 100) -> DataRequest?
    {
        //"https://api.vimeo.com/users/38955539/videos", // all LR videos on vimeo
        let headers = ["Authorization": "bearer 90f1eb5ac7ae775b0c363ab9890c8ddb"]
        let parameters = ["per_page": numberOfVideos]

        return Alamofire.request("https://api.vimeo.com/albums/3622274/videos",
                                 method: .get,
                                 parameters: parameters,
                                 encoding: URLEncoding.default,
                                 headers: headers)
    }
    
    func videosFromVimeoAlbumVideosJSONResponse(_ response: DataResponse<Any>)
    {
        switch response.result
        {
        case .success(let JSON):
            
            videosFromVimeoAlbumVideosDictionary(JSON)
            didLoadVimeoEpisodes()
            
        case .failure(_):
            
            //print("\nVimeo request failed with error:\n\(error)")
            
            loadingDidFail()
        }
    }
    
    func videosFromVimeoAlbumVideosDictionary(_ videosJSON: Any?)
    {
        guard let videosDic = videosJSON as? [String:AnyObject],
            let data = videosDic["data"] as? [AnyObject]
            else
        {
            return
        }
        
        for videoJSON in data
        {
            addVimeoVideoFromVideoJson(videoJSON)
        }
    }
    
    func addVimeoVideoFromVideoJson(_ videoJson: Any)
    {
        // create video with title
        guard let videoDic = videoJson as? [String:AnyObject],
            let name = videoDic["name"] as? String
        else
        {
            return
        }
        
        let video = Video()
        let title = episodeTitleFromJSONEpisodeTitle(name)
        video.title = title
        
        // set description
        if let description = videoDic["description"] as? String
        {
            video.description = description
        }
        
        // set other infos
        if let createdTimeString = videoDic["created_time"] as? String,
            let date = Date.dayFromJSONDateString(createdTimeString),
            let durationSeconds = videoDic["duration"] as? Int,
            let statsDic = videoDic["stats"] as? [String:AnyObject],
            let plays = statsDic["plays"] as? Int
        {
            
            if durationSeconds == 0
            {
                //print("got zero duration from vimeo for episode: " + title)
            }
            
            if durationSeconds == 0 && title == "Elliott Hulse - The Body Is The Mind"
            {
                video.duration = VideoTime(totalSeconds: 8207)
            }
            else if durationSeconds == 0 && title == "James Rhodes - Instrumental"
            {
                video.duration = VideoTime(totalSeconds: 3600 + 38 * 60 + 28)
            }
            else
            {
                video.duration = VideoTime(totalSeconds: durationSeconds)
            }
            
            video.publicationDate = date
            
            video.viewCount = plays
        }
        
        //print(video.title! + " was added to vimeo on " + video.publicationDate.text())
        
        // set image and file URLs
        video.imageURLString = imageURLStringFromVimeoVideoDictionary(videoDic)
        video.smallImageURLString = smallImageURLStringFromVimeoVideoDictionary(videoDic)
        video.fileURLString = fileURLStringFromVimeoVideoDictionary(videoDic)
        
        vimeoEpisodes[title.lowercased()] = video
    }
    
    func imageURLStringFromVimeoVideoDictionary(_ videoDic: [String:AnyObject]) -> String?
    {
        guard let imagesDic = videoDic["pictures"] as? [String:AnyObject],
            let sizes = imagesDic["sizes"] as? [AnyObject]
        else
        {
            return nil
        }
        
        var greatesWidth = 0
        var bestUrlString = ""
        
        for sizeJson in sizes
        {
            guard let imageDic = sizeJson as? [String:AnyObject],
                let urlString = imageDic["link"] as? String,
                let width = imageDic["width"] as? Int
            else
            {
                continue
            }
            
            if width > greatesWidth
            {
                greatesWidth = width
                bestUrlString = urlString
            }
        }
        
        return bestUrlString
    }
    
    func smallImageURLStringFromVimeoVideoDictionary(_ videoDic: [String:AnyObject]) -> String?
    {
        guard let imagesDic = videoDic["pictures"] as? [String:AnyObject],
            let sizes = imagesDic["sizes"] as? [AnyObject]
            else
        {
            return nil
        }
        
        var bestWidth = 100000
        var bestUrlString = ""
        
        for sizeJson in sizes
        {
            guard let imageDic = sizeJson as? [String:AnyObject],
                let urlString = imageDic["link"] as? String,
                let width = imageDic["width"] as? Int
                else
            {
                continue
            }
            
            if width < bestWidth && width >= 320
            {
                bestWidth = width
                bestUrlString = urlString
            }
        }
        
        return bestUrlString
    }
    
    func fileURLStringFromVimeoVideoDictionary(_ videoDic: [String:AnyObject]) -> String?
    {
        guard let files = videoDic["files"] as? [AnyObject] else
        {
            return nil
        }
    
        for fileJSON in files
        {
            if let fileDic = fileJSON as? [String:AnyObject],
                let quality = fileDic["quality"] as? String,
                let hlsUrlString = fileDic["link_secure"] as? String
            {
                if quality == "hls"
                {
                    return hlsUrlString
                }
            }
        }
        
        return nil
    }
    
    var vimeoEpisodes = [String:Video]()

    // MARK: Load Video Infos From Youtube Playlist
    
    func loadLatestEpisodesFromYoutubePlaylist()
    {
        guard let youtubeRequest = youtubeRequestForLatestEpisodes() else
        {
            return
        }
        
        youtubeRequest.responseJSON
        {
            response in
            
            self.videosFromYoutubePlaylistItemsJSONResponse(response)
        }
    }

    func youtubeRequestForLatestEpisodes() -> DataRequest?
    {
        var requestParameters = ["key": "AIzaSyBoOwTsr8szGakm9DC8IEKN6lpHxuw9Wa0"] // api key
        requestParameters["playlistId"] = "PLA0983D7EA3E2CDD1" // latest episodes
        requestParameters["part"] = "snippet" // if the item is a video
        requestParameters["maxResults"] = String(49) // page size
        //requestParameters["pageToken"] = "CAUQAA"
        
        return Alamofire.request("https://www.googleapis.com/youtube/v3/playlistItems",
                                 method: .get,
                                 parameters: requestParameters)
    }
    
    var nextPageToken: String?

    func videosFromYoutubePlaylistItemsJSONResponse(_ response: DataResponse<Any>)
    {
        switch response.result
        {
        case .success(let JSON):
            
            videosFromYoutubePlaylistItemsDictionary(JSON)
            loadStatisticsForVideosFromYoutube()
            
        case .failure(_):
            
            //print("\nYoutube request failed with error:\n\(error)")

            loadingDidFail()
        }
    }
    
    fileprivate func videosFromYoutubePlaylistItemsDictionary(_ playlistJSON: Any?)
    {
        guard let playlistDic = playlistJSON as? [String:AnyObject],
            let items = playlistDic["items"] as? [AnyObject]
        else
        {
            return
        }
        
        if let pageToken = playlistDic["nextPageToken"] as? String
        {
            nextPageToken = pageToken
        }
        
        for item in items
        {
            guard let itemDic = item as? [String:AnyObject] ,
                let snippetDic = itemDic["snippet"] as? [String:AnyObject],
                let titleString = snippetDic["title"] as? String,
                let description = snippetDic["description"] as? String,
                let publicationDateString = snippetDic["publishedAt"] as? String,
                let resourceDic = snippetDic["resourceId"] as? [String:AnyObject],
                let videoIDString = resourceDic["videoId"] as? String
            else
            {
                print("could not parse youtube video json item: " + (item as! String))
                continue
            }
            
            let title = episodeTitleFromJSONEpisodeTitle(titleString)
            
            let video = Video()
            video.title = title
            video.youtubeID = videoIDString
            video.description = description
            
            //print("youtube date: " + publicationDateString + " for " + title)
            
            if let date = Date.dayFromJSONDateString(publicationDateString)
            {
                video.publicationDate = date
            }
            youtubeStatisticsByTitle[title.lowercased()] = video
            youtubeStatisticsById[videoIDString] = video
        }
    }
    
    func getDescriptionFromYoutubeDescription(_ description: String?) -> String?
    {
        guard let ytDescription = description else
        {
            return nil
        }
        
        let regexOptions = NSString.CompareOptions([.regularExpression, .caseInsensitive])
        let cleanDescription = ytDescription.replacingOccurrences(of: "[\\u0000-\\U0010ffff]*((full)|(free)) episode:[\\u0000-\\U0010ffff]*?(http[s]?://)?londonrealacademy.com/episodes/[\\u0000-\\U0010ffff]*?(/)?\\n",
                                                                 with: "",
                                                                 options: regexOptions)
        return cleanDescription
    }
    
    // MARK: Load Video Statistics for Youtube Videos
    
    func loadStatisticsForVideosFromYoutube()
    {
        guard let request = createRequestForYoutubeVideoStatistics() else
        {
            return
        }
        
        request.responseJSON
        {
            response in
            
            self.setStatisticsForVideos(fromYoutubeVideosJSONResponse: response)
        }
    }
    
    func createRequestForYoutubeVideoStatistics() -> DataRequest?
    {
        // create comma separated list of video IDs
        var idListString = ""
        
        for youtubeVideoID in youtubeStatisticsById.keys
        {
            if idListString != ""
            {
               idListString += ","
            }

            idListString += youtubeVideoID
        }
        
        // create request
        var requestParameters = ["key": "AIzaSyBoOwTsr8szGakm9DC8IEKN6lpHxuw9Wa0"] // api key
        requestParameters["id"] = idListString // video IDs
        requestParameters["part"] = "statistics" // for duration and view count
        
        return Alamofire.request("https://www.googleapis.com/youtube/v3/videos",
                                 method: .get,
                                 parameters: requestParameters)
    }
    
    func setStatisticsForVideos(fromYoutubeVideosJSONResponse response: DataResponse<Any>)
    {
        switch response.result
        {
        case .success(let JSON):
            
            setStatisticsForVideos(fromYoutubeVideosDictionary: JSON)
            didLoadYoutubeStatistics()
            
        case .failure(_):
            
            //print("Request failed with error: \(error)")
            return
        }
    }
    
    fileprivate func setStatisticsForVideos(fromYoutubeVideosDictionary videosJSON: Any?)
    {
        guard let videosDic = videosJSON as? [String:AnyObject],
            let items = videosDic["items"] as? [AnyObject]//,
            //let nextPageToken = videosDic["nextPageToken"] as? String
        else
        {
            return
        }
        
        print(videosDic)
        
        for item in items
        {
            guard let itemDic = item as? [String:AnyObject],
                let youtubeVideoID = itemDic["id"] as? String,
                let statisticsDic = itemDic["statistics"] as? [String:AnyObject],
                let viewCountString = statisticsDic["viewCount"] as? String,
                let likesString = statisticsDic["likeCount"] as? String,
                let dislikesString = statisticsDic["dislikeCount"] as? String,
                let video = youtubeStatisticsById[youtubeVideoID]
            else
            {
                //print("couldn't load statistics from youtube video item: " + String(item))
                continue
            }
            
            if let viewCount = Int(viewCountString),
                let likes = Int(likesString),
                let dislikes = Int(dislikesString)
            {
                video.viewCount = viewCount
                video.likes = likes
                video.dislikes = dislikes
            }
        }
    }
    
    var youtubeStatisticsByTitle = [String:Video]()
    var youtubeStatisticsById = [String:Video]()
    
    // MARK: Load Academy Tour
    
    func loadAcademyTourFromVimeo()
    {
        guard let vimeoRequest = vimeoRequestForAcademyTour() else
        {
            return
        }
        
        vimeoRequest.responseJSON
            {
                response in
                
                self.addAcademyTourFromVimeoVideoJSONResponse(response)
        }
    }
    
    func vimeoRequestForAcademyTour() -> DataRequest?
    {
        let headers = ["Authorization": "bearer 90f1eb5ac7ae775b0c363ab9890c8ddb"]
        let parameters = ["per_page": 1]
        
        //"https://api.vimeo.com/users/38955539/videos", // all LR videos on vimeo
        
        return Alamofire.request("https://api.vimeo.com/videos/144066014",
                                 method: .get,
                                 parameters: parameters,
                                 encoding: URLEncoding.default,
                                 headers: headers)
    }
    
    func addAcademyTourFromVimeoVideoJSONResponse(_ response: DataResponse<Any>)
    {
        switch response.result
        {
        case .success(let JSON):
            
            addVimeoVideoFromVideoJson(JSON)
            didLoadVimeoAcademyTour()
            
        case .failure(_):
            
            //print("\nVimeo request failed with error:\n\(error)")
            
            loadingDidFail()
        }
    }
    
    fileprivate func addAcademyTourYoutubeVideo()
    {
        let video = Video()
        
        let title = academyVideoTitle
        let id = "pkHve5BITm0"
        
        video.title = title
        video.youtubeID = id
        
        youtubeStatisticsByTitle[title.lowercased()] = video
        youtubeStatisticsById[id] = video
    }
    
    let academyVideoTitle = "BUILD THE BEST YOU"
    
    // MARK: Syncing Response Handling
    
    func didLoadVimeoAcademyTour()
    {
        if vimeoEpisodesLoaded
        {
            didLoadVimeoVideos()
        }
        
        vimeoAcademyTourLoaded = true
    }
    
    func didLoadVimeoEpisodes()
    {
        if vimeoAcademyTourLoaded || loadingSynchronously
        {
            didLoadVimeoVideos()
        }
        
        vimeoEpisodesLoaded = true
    }
    
    func didLoadVimeoVideos()
    {
        addChaptersFromJsonFileToVimeoVideos()
        
        if loadingSynchronously
        {
            loadingSynchronously = false
            
            resultsArray = Array(vimeoEpisodes.values)
            
            // leave dispatch group
            if let group = self.synchronousLoadingDispatchGroup
            {
                group.leave()
            }
            
            return
        }
        
        if youtubeStatisticsLoaded
        {
            didLoadVimeoVideosAndYoutubeStatistics()
        }
        
        vimeoVideosLoaded = true
    }
    
    func addChaptersFromJsonFileToVimeoVideos()
    {
        guard let fileUrl = URL(string: "http://flowtoolz.com/londonreal/app_data/chapter_timestamps_v1.json"),
            let jsonFileData = try? Data(contentsOf: fileUrl)
        else
        {
            return
        }
        
        var jsonFileObject: Any?
        
        do
        {
            jsonFileObject = try JSONSerialization.jsonObject(with: jsonFileData, options: [])
        }
        catch let error as NSError
        {
            print("could not serialize chapter json file: \(error.localizedDescription)")
            return
        }
        
        guard let dictionary = jsonFileObject as? [String:AnyObject],
            let episodesDictionary = dictionary["episodes_by_lowercase_title"] as? [String:AnyObject]
        else
        {
            print("could not find episode dictionary in chapter json file")
            return
        }
        
        for vimeoVideo in vimeoEpisodes.values
        {
            guard let lowercaseTitle = vimeoVideo.title?.lowercased(),
                let episodeDictionary = episodesDictionary[lowercaseTitle],
                let chapters = episodeDictionary["chapters"] as? [AnyObject]
            else
            {
                //print("could not get chapter array from chapter json file for episode " + vimeoVideo.title!)
                
                vimeoVideo.createDefaultChapters()
                
                continue
            }
            
            for chapter in chapters
            {
                guard let chapterDictionary = chapter as? [String:AnyObject],
                    let title = chapterDictionary["title"] as? String,
                    let timeDictionary = chapterDictionary["time"] as? [String:AnyObject],
                    let hours = timeDictionary["hours"] as? Int,
                    let minutes = timeDictionary["minutes"] as? Int,
                    let seconds = timeDictionary["seconds"] as? Int
                    else
                {
                    print("could not parse chapter details")
                    continue
                }
                
                var videoTime = VideoTime()
                videoTime.hours = hours
                videoTime.minutes = minutes
                videoTime.seconds = seconds
                
                let videoChapter = VideoChapter(time: videoTime, description: title)
                
                vimeoVideo.chapters.append(videoChapter)
            }
        }
    }
    
    func didLoadYoutubeStatistics()
    {
        if vimeoVideosLoaded
        {
            didLoadVimeoVideosAndYoutubeStatistics()
        }
        
        youtubeStatisticsLoaded = true
    }
    
    func didLoadVimeoVideosAndYoutubeStatistics()
    {
        guard let delegate = delegate else
        {
            return
        }
        
        // update vimeo videos with data from youtube videos
        let titleKeys = Array(vimeoEpisodes.keys)
        print(vimeoEpisodes.count)
        
        for titleKey in titleKeys
        {
            guard let vimeoEpisode = vimeoEpisodes[titleKey] else
            {
                continue
            }
            
            guard let youtubeVideo = youtubeStatisticsByTitle[titleKey] else
            {
                //print("couldn't get youtube statistics for key " + titleKey)
                
                vimeoEpisodes.removeValue(forKey: titleKey)
                continue
            }
            
            vimeoEpisode.viewCount += youtubeVideo.viewCount
            vimeoEpisode.likes = youtubeVideo.likes
            vimeoEpisode.dislikes = youtubeVideo.dislikes
            
            /*
            // hack to get certain guest images
            if let title = vimeoEpisode.title
            {
                if (title.contains("Vaynerchuk") ||
                    title.contains("Dan Pena") ||
                    title.contains("Simon Sinek") ||
                    title.contains("Lawrence Krauss") ||
                    title.contains("Ido Portal") ||
                    title.contains("Ryan Holiday") ||
                    title.contains("Jocko") ||
                    title.contains("Michael") ||
                    title.contains("Wim Hof"))
                {
                    print(vimeoEpisode.imageURLString!)
                }
            }
             */
            
            
            if (youtubeVideo.publicationDate < vimeoEpisode.publicationDate)
            {
                //print("using youtube date for key " + titleKey)
                vimeoEpisode.publicationDate = youtubeVideo.publicationDate
            }
            
            /*
            // hack for analytics: see viewcount as views/day
            let secondsSincePublication = abs(vimeoEpisode.publicationDate.timeIntervalSinceNow)
            let hoursSincePublication = secondsSincePublication / 3600
            let daysSincePublication = hoursSincePublication / 24
            vimeoEpisode.viewCount = Int(Double(vimeoEpisode.viewCount) / daysSincePublication)
            */
            
            if vimeoEpisode.description == nil || vimeoEpisode.description == ""
            {
               vimeoEpisode.description = getDescriptionFromYoutubeDescription(youtubeVideo.description)
            }
        }
        
        // sort by publication date, put academy video first
        resultsArray = Array(vimeoEpisodes.values)
        sortResults()
        
        // done loading
        delegate.videoLoaderDidLoad(resultsArray)
    }
    
    func sortResults()
    {
        resultsArray.sort(
            by: {
                if $0.title == academyVideoTitle
                {
                    return true
                }
                
                if $1.title == academyVideoTitle
                {
                    return false
                }
                
                return $1.publicationDate < $0.publicationDate
            }
        )
    }
    
    var vimeoAcademyTourLoaded = false
    var vimeoEpisodesLoaded = false
    var vimeoVideosLoaded = false
    var youtubeStatisticsLoaded = false
    
    var resultsArray = [Video]()
    
    // MARK: Parsing JSON
    
    func episodeTitleFromJSONEpisodeTitle(_ jsonTitle: String) -> String
    {
        var title = jsonTitle
        
        title = title.replacingOccurrences(of: "–", with: "-") // first one is different even if it doesn't look different in XCode!
        title = title.replacingOccurrences(of: "| London Real", with: "")
        title = title.replacingOccurrences(of: "PART 1/2", with: "")
        title = title.replacingOccurrences(of: "(Part 1 & 2)", with: "")
        title = title.replacingOccurrences(of: "REDUX", with: "")
        title = title.replacingOccurrences(of: "Dr ", with: "Dr. ")
        title = title.replacingOccurrences(of: "  ", with: " ")
        title = title.replacingOccurrences(of: "ñ", with: "n")
        title = title.trimmingCharacters(in: CharacterSet(charactersIn: " -|"))
        
        return title
    }
    
    // MARK: Error Handlng
    
    func loadingDidFail()
    {
        if !loadingFailed
        {
            postRequestFailedNotification()
        }
        
        loadingFailed = true
        
        loadingSynchronously = false
    }
    
    var loadingFailed = false
    
    func postRequestFailedNotification()
    {
        let nc = NotificationCenter.default
        
        nc.post(name: Notification.Name(rawValue: WebVideoLoader.RequestFailedNotification), object: nil)
    }
    
    static let RequestFailedNotification = "RequestFailedNotification"
}
