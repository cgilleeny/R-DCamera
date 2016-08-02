//
//  String+Utilities.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/16/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

extension String {
    
    func appendLineToURL(fileURL: NSURL) throws {
        try self.stringByAppendingString("\n").appendToURL(fileURL)
    }

    
    func appendToURL(fileURL: NSURL) throws {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        try data.appendToURL(fileURL)
    }
    
}
