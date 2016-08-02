//
//  CFString+Utilities.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 5/6/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import Foundation

extension CFString {
    
    func swiftString() -> String {
        let nsTypeString = self as NSString
        return nsTypeString as String
    }
}
