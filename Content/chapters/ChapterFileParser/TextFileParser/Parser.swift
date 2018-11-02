//
//  Parser.swift
//  TextFileParser
//
//  Created by Sebastian on 02/11/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

class Parser : NSObject
{
    func parseText(_ text: String)
    {
        var lines = [String]()
        
        text.enumerateLines
        {
            (line, someBool) in
            
            lines.append(line)
        }
        
        var jsonString = ""
        
        for i in 0 ..< lines.count
        {
            let line = lines[i]
            
            if let jsonCode = self.parseLine(line)
            {
                
                let lastIndex = jsonCode.index(jsonCode.endIndex, offsetBy: -1)
                let lastChar = jsonCode.substring(from: lastIndex)
                
                if lastChar == "}" && i < lines.count - 1 && lines[i + 1].length() > 2
                {
                    jsonString.append(jsonCode + ",\n")
                }
                else
                {
                    jsonString.append(jsonCode + "\n")
                }
                
            }
        }
        
        jsonString.append("\t]\n}\n")
        
        print(jsonString)
        
        if stringIsJSONCompliant(string: "{" + jsonString + "}")
        {
            print("result is json compliant")
        }
        else
        {
            print("result is NOT json compliant")
        }
    }
    
    func parseLine(_ line: String) -> String?
    {
        // empty lines signify the episode is complete and the next will begin in th enext line
        if line.length() < 3
        {
            return "\t]\n},"
        }
        
        // get first timestamp that occurs in this line
        let timeStampRegularExpression = "[0-5]?([0-9]:)?[0-5][0-9]:[0-5][0-9]"
        let timeStampStrings = matches(timeStampRegularExpression, line)
        
        // if the line contains no time stamp, it should be "guest name - episode title"
        if timeStampStrings.count == 0
        {
            if !stringIsJSONCompliant(string: line.lowercased())
            {
                return nil
            }
            return "\"" + line.lowercased() + "\":\n{\n\t\"chapters\":\n\t["
        }
        
        // if there is a timestamp...
        if let timeStampString = timeStampStrings.first
        {
            // ... a title should follow -> extract it
            let numberOfSpaceBetweenTimeStampAndTitle = 1
            let titleOffset = timeStampString.length() + numberOfSpaceBetweenTimeStampAndTitle
            let titleStartIndexindex = line.index(line.startIndex, offsetBy: titleOffset)
            
            var title = line.substring(from: titleStartIndexindex).trimmingCharacters(in: CharacterSet(charactersIn: " ."))
            
            // escape ", \ and /
            title = title.replacingOccurrences(of: "\"", with: "\\\"")
            title = title.replacingOccurrences(of: "\\", with: "\\\\")
            title = title.replacingOccurrences(of: "/", with: "\\/")
            title = title.replacingOccurrences(of: "/", with: "\\/")
            
            // remove control characters
            title = title.replacingOccurrences(of: "\n", with: "")
            title = title.replacingOccurrences(of: "\r", with: "")
            title = title.replacingOccurrences(of: "\t", with: "")

            // test if the chapter title is json compliant
            if !stringIsJSONCompliant(string: title)
            {
                return nil
            }
            
            // get minutes, seconds, hours
            let timeComponentStrings = timeStampString.components(separatedBy: ":")
            
            var hours = 0
            var minutes = Int(timeComponentStrings[0])!
            var seconds = Int(timeComponentStrings[1])!
            
            if timeComponentStrings.count == 3
            {
                hours = Int(timeComponentStrings[0])!
                minutes = Int(timeComponentStrings[1])!
                seconds = Int(timeComponentStrings[2])!
            }
            
            return "\t\t{\"time\":{\"hours\": \(hours), \"minutes\": \(minutes), \"seconds\": \(seconds)}, \"title\": \"" + title + "\"}"
        }
        
        return nil
    }
    
    func stringIsJSONCompliant(string: String) -> Bool
    {
        do
        {
            let jsonString = "{\"key\":\"\(string)\"}"
            if let jsonData = jsonString.data(using: .utf8)
            {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            }
        }
        catch let error as NSError
        {
            print("error: could not use string in json format: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    func matches(_ regex: String, _ text: String) -> [String]
    {
        do
        {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        }
        catch let error
        {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
