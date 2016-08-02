//
//  NSData+Utilities.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/16/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

extension NSData {
    
    func appendToURL(fileURL: NSURL) throws {
        if let fileHandle = try? NSFileHandle(forWritingToURL: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.writeData(self)
        }
        else {
            try writeToURL(fileURL, options: .DataWritingAtomic)
        }
    }
}

