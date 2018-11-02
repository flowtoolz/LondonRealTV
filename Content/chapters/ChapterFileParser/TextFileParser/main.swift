//
//  main.swift
//  TextFileParser
//
//  Created by Sebastian on 25/10/16.
//  Copyright © 2016 Flowtoolz. All rights reserved.
//

import Foundation

let text = TextFileReader.readTextFromFile()
Parser().parseText(text)

