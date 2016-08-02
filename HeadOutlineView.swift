//
//  HeadOutlineView.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/6/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

class HeadOutlineView: UIView {

    override func drawRect(rect: CGRect) {

         let ellipsePath = UIBezierPath(ovalInRect: CGRectInset(rect, 30.0, 40.0))
         
         let shapeLayer = CAShapeLayer()
         shapeLayer.path = ellipsePath.CGPath
         shapeLayer.fillColor = UIColor.clearColor().CGColor
         shapeLayer.strokeColor = UIColor.yellowColor().CGColor
         shapeLayer.lineWidth = 5.0
         
         self.layer.addSublayer(shapeLayer)
    }
}
