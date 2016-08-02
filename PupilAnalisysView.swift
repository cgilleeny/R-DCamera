//
//  PupilAnalisysView.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/16/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

class PupilAnalisysView: UIView {

    var patient:Patient!
    let textBoxGrey = UIColor(red: 0xF5/0xFF, green: 0xF5/0xFF, blue: 0xF5/0xFF, alpha: 1)
    let titleBoxGrey = UIColor(red: 0xD0/0xFF, green: 0xD0/0xFF, blue: 0xD0/0xFF, alpha: 1)
    let verticalOffset: CGFloat = 2.0
    let horizontalOffset: CGFloat = 2.0
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        var rowRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/11)
        CGContextSetFillColorWithColor(context, titleBoxGrey.CGColor)
        CGContextFillRect(context, rowRect)
        
        for i in 0 ... 10 {
            rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
            if i % 2 != 0 {
                CGContextSetFillColorWithColor(context, textBoxGrey.CGColor)
                CGContextFillRect(context, rowRect)
            }
        }
        
        var colRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width/5, rect.size.height)
        drawLeftColumn(colRect)
        
        colRect = CGRectMake(colRect.origin.x + colRect.size.width, colRect.origin.y, (rect.size.width/5)*2, colRect.size.height)
        drawDataColumn(colRect, eye: "Left Eye", contour: patient.contourLeft!, difference: patient.differenceLeft!)
        
        
        CGContextMoveToPoint(context, colRect.origin.x - 0.5, colRect.origin.y)
        CGContextAddLineToPoint(context, colRect.origin.x - 0.5, colRect.origin.y + colRect.size.height)
        CGContextStrokePath(context)
        
        colRect = CGRectMake(colRect.origin.x + colRect.size.width, colRect.origin.y, colRect.size.width, colRect.size.height)
        drawDataColumn(colRect, eye: "Right Eye", contour: patient.contourRight!, difference: patient.differenceRight!)
        
        CGContextMoveToPoint(context, colRect.origin.x - 0.5, colRect.origin.y)
        CGContextAddLineToPoint(context, colRect.origin.x - 0.5, colRect.origin.y + colRect.size.height)
        CGContextStrokePath(context)
        
        CGContextStrokePath(context)
    }


    func drawLeftColumn(rect: CGRect) {
        //let context = UIGraphicsGetCurrentContext()
        let p = NSMutableParagraphStyle()
        p.alignment = .Left
        p.lineBreakMode = .ByClipping
        
        var rowRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/11)
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        var attrString = NSAttributedString(
            string: "Red",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: "Green",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: "Blue",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: "Total Pixels",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: "Red",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: "Green",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: "Blue",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: "Total Pixels",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
    }
    
    func drawDataColumn(rect: CGRect, eye: String, contour: PupilROI, difference: PupilROI) {
        //let context = UIGraphicsGetCurrentContext()
        let p = NSMutableParagraphStyle()
        p.alignment = .Left
        p.lineBreakMode = .ByClipping
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        
        var rowRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/11)
        var attrString = NSAttributedString(
            string: eye,
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: "Contour",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: String(format: "%@ avg: %@", numberFormatter.stringFromNumber(contour.red!)!, (contour.totalPixels! == 0) ? "0" : numberFormatter.stringFromNumber(Double(contour.red!)/Double(contour.totalPixels!))!),
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: String(format: "%@ avg: %@", numberFormatter.stringFromNumber(contour.green!)!, (contour.totalPixels! == 0) ? "0" : numberFormatter.stringFromNumber(Double(contour.green!)/Double(contour.totalPixels!))!),
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: String(format: "%@ avg: %@", numberFormatter.stringFromNumber(contour.blue!)!, (contour.totalPixels! == 0) ? "0" : numberFormatter.stringFromNumber(Double(contour.blue!)/Double(contour.totalPixels!))!),
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: String(format: "%@", numberFormatter.stringFromNumber(contour.totalPixels!)!),
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        attrString = NSAttributedString(
            string: "Difference",
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: String(format: "%@ avg: %@", numberFormatter.stringFromNumber(difference.red!)!, (difference.totalPixels! == 0) ? "0" : numberFormatter.stringFromNumber(Double(difference.red!)/Double(difference.totalPixels!))!),
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: String(format: "%@ avg: %@", numberFormatter.stringFromNumber(difference.green!)!, (difference.totalPixels! == 0) ? "0" : numberFormatter.stringFromNumber(Double(difference.green!)/Double(difference.totalPixels!))!),
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: String(format: "%@ avg: %@", numberFormatter.stringFromNumber(difference.blue!)!, (difference.totalPixels! == 0) ? "0" : numberFormatter.stringFromNumber(Double(difference.blue!)/Double(difference.totalPixels!))!),
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
        
        rowRect = CGRectMake(rowRect.origin.x, rowRect.origin.y + rowRect.size.height, rowRect.size.width, rowRect.size.height)
        
        attrString = NSAttributedString(
            string: String(format: "%@", numberFormatter.stringFromNumber(difference.totalPixels!)!),
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(15.0), NSParagraphStyleAttributeName : p])
        attrString.drawInRect(CGRectInset(rowRect, horizontalOffset, verticalOffset))
    }

}
