//
//  Logger.swift
//  BackgroundLocation
//
//  Created by Rajan Maheshwari on 27/12/19.
//  Copyright © 2019 Rajan Maheshwari. All rights reserved.
//

import Foundation

public class Logger {

    public class func write(text: String, to fileNamed: String = "LocationLogs", folder: String = "LocationData") {
        let textToBeAppended = "\(Date()) "+text+"\n"
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return }
        print(writePath.absoluteString)
        let file = writePath.appendingPathComponent(fileNamed + ".txt")
        
        if let fileHandle = FileHandle(forWritingAtPath: file.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(textToBeAppended.data(using: .utf8)!)
        } else {
            print("File doesn't exists")
            try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
            try? textToBeAppended.write(to: file, atomically: false, encoding: String.Encoding.utf8)
        }
    }
}

