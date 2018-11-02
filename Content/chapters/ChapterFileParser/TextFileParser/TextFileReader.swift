//
//  TextFileReader.swift
//  TextFileParser
//
//  Created by Sebastian on 02/11/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class TextFileReader
{
    static func readTextFromFile() -> String
    {
        let fm = FileManager()
        
        let filePath = fm.currentDirectoryPath + "/chapters_not_yet_in_app.txt"
        
        var contentString = ""
        
        do
        {
            contentString = try String(contentsOfFile: filePath)
        }
        catch
        {
            print("could not read file")
        }
        
        return contentString
    }
}
