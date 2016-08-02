//
//  UIImage+OpenCV.mm
//  OpenCVClient
//
//  Created by Washe on 01/12/2012.
//  Copyright 2012 Washe / Foundry. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//  adapted from
//  http://docs.opencv.org/doc/tutorials/ios/image_manipulation/image_manipulation.html#opencviosimagemanipulation

#import "UIImage+OpenCV.h"


@implementation UIImage (OpenCV)


-(cv::Mat)CVMat
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)CVMat3
{
    cv::Mat result = [self CVMat];
    cv::cvtColor(result , result , CV_RGBA2RGB);
    return result;

}


- (UTF8Char*)CVMatHSV:(int)x withY:(int)y
{
    cv::Mat result = [self CVMat];

    
    //[self CVLog:result withRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    cv::Vec3b pixel = result.at<cv::Vec3b>(y, x);
    static UTF8Char hsv [3];
    hsv[0] = pixel.val[0];
    hsv[1] = pixel.val[1];
    hsv[2] = pixel.val[2];

    return hsv;
}

- (UTF8Char*)CVRGBPixelToHSV:(int)x atY:(int)y
{
    cv::Mat rgbMat = [self CVMat3];
    cv::Mat hsvMat;
    cv::cvtColor(rgbMat ,hsvMat , CV_RGB2HSV);
    //cv::Vec3b pixel = rgbMat.at<cv::Vec3b>(x, y);
    //cv::Mat pixelMat = cv::Mat(1, 1, CV_8UC3, cv::Scalar(pixel.val[0], pixel.val[1], pixel.val[2]));
    //cv::Mat hsvMat = cv::Mat(1,1, CV_8UC3, cv::Scalar(0, 0, 0));
    //cv::cvtColor(rgbMat ,hsvMat , CV_RGB2HSV);
    static UTF8Char results [3] = {0,0,0};

    cv::Vec3b hsv = hsvMat.at<cv::Vec3b>(y, x);
    results[0] = hsv.val[0];
    results[1] = hsv.val[1];
    results[2] = hsv.val[2];
    
    return results;
}

- (UInt32*)CVGetPixelSumFromPupil:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax withMinSkinRatio:(float)minSkinRatio withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier
{
    cv::Mat eyeROIrgb = [self CVMat3];
    cv::Mat eyeROIhsv;;
    
    cv::cvtColor(eyeROIrgb ,eyeROIhsv , CV_RGB2HSV);
    
    // create mask image with black circle to mask eye area and expose the skin for pixel analysis
    cv::Mat mask(eyeROIrgb.size(), eyeROIrgb.type());
    mask.setTo(cv::Scalar(255, 255, 255));
    cv::circle(mask, cv::Point2f(self.size.width/2, self.size.height/2), self.size.width/2, cv::Scalar(0, 0, 0), -1, 8, 0);
    
    // create corners image from masked RGB image
    cv::Mat corners;
    cv::bitwise_and(eyeROIrgb, mask, corners);
    std::vector<cv::Mat>  maskChannels = std::vector<cv::Mat>();
    cv::split(corners, maskChannels);
    double cornerPixelTotal = cv::countNonZero(maskChannels[0]);
    
    // convert RGB corners to HSV and split into channels
    cv::Mat cornersHSV;
    cv::cvtColor(corners ,cornersHSV , CV_RGB2HSV);
    std::vector<cv::Mat>  cornerChannels = std::vector<cv::Mat>();
    cv::split(cornersHSV, cornerChannels);
    cv::Mat cornersHue = cornerChannels[0];
    cv::Mat cornersSat = cornerChannels[1];
    cv::Mat cornersVal = cornerChannels[2];

    // filter the Hue channel for values in the upper wheel red area 0..30
    int avgCornerVal = 0;
    cv::inRange(cornersHue, cv::Scalar(0), cv::Scalar(30), cornersHue);
    NSLog(@"cv::countNonZero(cornersHue): %d, cornersHue.total(): %zu, ratio: %f", cv::countNonZero(cornersHue), cornersHue.total(), (double)cv::countNonZero(cornersHue) / (double)cornersHue.total());
    // zero out the values for pixels that are outside the target hues of 0..30
    cv::bitwise_and(cornersHue, cornersVal, cornersVal);
    
    if ((double)cv::countNonZero(cornersVal) / (double)cornersVal.total() > minSkinRatio) {
        // get avg of non zero values of skin pixels with red hue
        avgCornerVal = (cv::countNonZero(cornersVal) > 0)?cv::sum(cornersVal).val[0]/cv::countNonZero(cornersVal):0;
    }
    
    

    
    NSLog(@"cv::sum(cornersVal).val[0]: %f, cv::countNonZero(cornersVal): %d, avgCornerVal: %d", cv::sum(cornersVal).val[0], cv::countNonZero(cornersVal), avgCornerVal /*, valMean.val[0]*/);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();
    
    cv::split(eyeROIhsv, channels);
    
    cv::Mat hue = channels[0];
    cv::Mat sat = channels[1];
    cv::Mat val = channels[2];
    
    cv::Mat redLowerWheel;
    cv::Mat redUpperWheel;
    
    cv::inRange(hue, cv::Scalar(0), cv::Scalar(lowerWheelMax), redLowerWheel);
    cv::bitwise_and(cornersHue, cornersSat, cornersSat);
    int avgCornerSat = 0;
    if ((double)cv::countNonZero(cornersSat) / cornerPixelTotal > minSkinRatio) {
        // get avg of non zero values of skin pixels with red hue
        avgCornerSat = (cv::countNonZero(cornersSat) > 0)?cv::sum(cornersSat).val[0]/cv::countNonZero(cornersSat):0;
    }

    /*
    if (avgCornerVal > 0) {
        NSLog(@"cv::countNonZero(val): %d", cv::countNonZero(val));
        cv::Scalar maxValThresh = cv::Scalar(avgCornerVal*skinValMultiplier);
        cv::inRange(val, cv::Scalar(0), maxValThresh, val);
        NSLog(@"maxValThresh.val[0]: %f, cv::countNonZero(val): %d", maxValThresh.val[0], cv::countNonZero(val));
        cv::bitwise_and(redLowerWheel, val, redLowerWheel);
    }
    */
    if (avgCornerSat > 0) {
        NSLog(@"cv::countNonZero(sat): %d", cv::countNonZero(sat));
        cv::Scalar minSatThresh = cv::Scalar(avgCornerSat*1.35);
        cv::inRange(sat, minSatThresh, cv::Scalar(255), sat);
        NSLog(@"minSatThresh.val[0]: %f, cv::countNonZero(sat): %d", minSatThresh.val[0], cv::countNonZero(sat));
        cv::bitwise_and(redLowerWheel, sat, redLowerWheel);
    }
    
    cv::inRange(hue, cv::Scalar(upperWheelMin), cv::Scalar(179), redUpperWheel);
    cv::max(redLowerWheel, redUpperWheel, hue);
    
    cv::equalizeHist(hue, hue);
    cv::GaussianBlur(hue, hue, cv::Size(3.0, 3.0), 0);
    cv::threshold(hue, hue, thresh, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(hue, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        //cv::rectangle(eyeROIrgb, rect, cv::Scalar(0,255,255), 0);
        NSLog(@"[%d x %d] %f", rect.width, rect.height, std::abs(1 - ((double)rect.width / (double)rect.height)));
        NSLog(@"contour area: %f, bounding rect area: %f", area, (double)rect.width*(double)rect.height);
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < ratio * self.size.width * self.size.height
            && area/((double)rect.width*(double)rect.height) > 0.33) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    
    if (largestContour.empty()){
        return nil;
    }
    
    static UInt32 results [24] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (int i = 0; i < 24; i++) {
        results[i] = 0;
    }

    
    cv::Point2f center = cv::Point2f(0,0);
    float radius = 0;
    cv::minEnclosingCircle(largestContour, center, radius);
    CvRect boundingRect = cv::boundingRect(largestContour);
    NSLog(@"largest Contour [%d x %d] %f", boundingRect.width, boundingRect.height, std::abs(1 - ((double)boundingRect.width / (double)boundingRect.height)));
    
    std::vector<cv::Point2f>  contourF;
    cv::Mat(largestContour).copyTo(contourF);
    cv::Mat(largestContour).convertTo(contourF, cv::Mat(contourF).type());
    
    //NSLog(@"eye: (%f, %f, %f, %f)\n", eye.origin.x, eye.origin.y, eye.size.width, eye.size.height);
    //NSLog(@"boundingRect: (%d, %d, %d, %d)\n", boundingRect.x, boundingRect.y, boundingRect.width, boundingRect.height);
    //NSLog(@"circle: (%f, %f, %f)", center.x, center.y, radius);
    for(int y = boundingRect.y; y < boundingRect.y + boundingRect.height; y++) {
        for(int x = boundingRect.x; x < boundingRect.x + boundingRect.width; x++) {
            if (isPointInCircle(center.x, center.y, radius, x, y)) {
                cv::Point p = cv::Point(x, y);
                cv::Vec3b pixelRGB = eyeROIrgb.at<cv::Vec3b>(y, x);
                cv::Vec3b pixelHSV = eyeROIhsv.at<cv::Vec3b>(y, x);
                //NSLog(@"pixel(%d, %d) = (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                if (cv::pointPolygonTest(contourF, p, false) >= 0) {
                    results[0] += pixelRGB.val[0];
                    results[1] += pixelRGB.val[1];
                    results[2] += pixelRGB.val[2];
                    results[3] += 1;
                    if (pixelHSV.val[0] >= 0 && pixelHSV.val[0] <= 30) {
                        results[8] += pixelHSV.val[0];
                        results[9] += pixelHSV.val[1];
                        results[10] += pixelHSV.val[2];
                        results[11] += 1;
                    } else {
                        results[12] += pixelHSV.val[0];
                        results[13] += pixelHSV.val[1];
                        results[14] += pixelHSV.val[2];
                        results[15] += 1;
                    }

                } else {
                    results[4] += pixelRGB.val[0];
                    results[5] += pixelRGB.val[1];
                    results[6] += pixelRGB.val[2];
                    results[7] += 1;
                    
                    if (pixelHSV.val[0] >= 0 && pixelHSV.val[0] <= 30) {
                        results[16] += pixelHSV.val[0];
                        results[17] += pixelHSV.val[1];
                        results[18] += pixelHSV.val[2];
                        results[19] += 1;
                    } else {
                        results[20] += pixelHSV.val[0];
                        results[21] += pixelHSV.val[1];
                        results[22] += pixelHSV.val[2];
                        results[23] += 1;
                    }
                }
            }
        }
    }
    return results;
}

-(UIImage *)CVAfterPrcocessID:(int)process withUpperWheelMin:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax withMinSkinRatio:(float)minSkinRatio withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier
{
    cv::Mat eyeROIrgb = [self CVMat3];
    cv::Mat eyeROIhsv; 
    
    cv::cvtColor(eyeROIrgb ,eyeROIhsv , CV_RGB2HSV);
    
    cv::Mat reverseMask(eyeROIrgb.size(), eyeROIrgb.type());
    reverseMask.setTo(cv::Scalar(0, 0, 0));
    cv::circle(reverseMask, cv::Point2f(self.size.width/2, self.size.height/2), self.size.width/2, cv::Scalar(255, 255, 255), -1, 8, 0);
    
    // create corners image from masked RGB image
    cv::Mat innerCircle;
    cv::bitwise_and(eyeROIrgb, reverseMask, innerCircle);
    std::vector<cv::Mat>  reverseMaskChannels = std::vector<cv::Mat>();
    cv::split(innerCircle, reverseMaskChannels);
    NSLog(@"cv::countNonZero(reverseMaskChannels[0]): %d, reverseMaskChannels[0].total(): %zu, ratio: %f", cv::countNonZero(reverseMaskChannels[0]), reverseMaskChannels[0].total(), (double)cv::countNonZero(reverseMaskChannels[0]) / (double)reverseMaskChannels[0].total());
    NSLog(@"cv::countNonZero(reverseMaskChannels[1]): %d, reverseMaskChannels[1].total(): %zu, ratio: %f", cv::countNonZero(reverseMaskChannels[1]), reverseMaskChannels[1].total(), (double)cv::countNonZero(reverseMaskChannels[1]) / (double)reverseMaskChannels[1].total());
    NSLog(@"cv::countNonZero(reverseMaskChannels[2]): %d, reverseMaskChannels[2].total(): %zu, ratio: %f", cv::countNonZero(reverseMaskChannels[2]), reverseMaskChannels[2].total(), (double)cv::countNonZero(reverseMaskChannels[2]) / (double)reverseMaskChannels[2].total());
    // convert RGB corners to HSV and split into channels
    cv::Mat innerCircleHSV;
    cv::cvtColor(innerCircle , innerCircleHSV , CV_RGB2HSV);
    std::vector<cv::Mat>  innerCircleChannels = std::vector<cv::Mat>();
    cv::split(innerCircleHSV, innerCircleChannels);
    cv::Mat innerCircleHue = innerCircleChannels[0];
    cv::Mat innerCircleSat = innerCircleChannels[1];
    cv::Mat innerCircleVal = innerCircleChannels[2];
    
    cv::inRange(innerCircleHue, cv::Scalar(0), cv::Scalar(30), innerCircleHue);
    
    cv::bitwise_and(innerCircleHue, innerCircleSat, innerCircleSat);
    int avgInnerCircleSat = (cv::countNonZero(innerCircleSat) > 0)?cv::sum(innerCircleSat).val[0]/cv::countNonZero(innerCircleSat):0;
    NSLog(@"cv::sum(innerCircleSat).val[0]: %f, cv::countNonZero(innerCircleSat): %d, avgInnerCircleSat: %d", cv::sum(innerCircleSat).val[0], cv::countNonZero(innerCircleSat), avgInnerCircleSat);
    
    cv::bitwise_and(innerCircleHue, innerCircleVal, innerCircleVal);
    int avgInnerCircleVal = (cv::countNonZero(innerCircleVal) > 0)?cv::sum(innerCircleVal).val[0]/cv::countNonZero(innerCircleVal):0;
    NSLog(@"cv::sum(innerCircleVal).val[0]: %f, cv::countNonZero(innerCircleVal): %d, avgInnerCircleVal: %d", cv::sum(innerCircleVal).val[0], cv::countNonZero(innerCircleVal), avgInnerCircleVal);
    
    
    
    // create mask image with black circle to mask eye area and expose the skin for pixel analysis
    cv::Mat mask(eyeROIrgb.size(), eyeROIrgb.type());
    mask.setTo(cv::Scalar(255, 255, 255));
    cv::circle(mask, cv::Point2f(self.size.width/2, self.size.height/2), self.size.width/2, cv::Scalar(0, 0, 0), -1, 8, 0);
    
    // create corners image from masked RGB image
    cv::Mat corners;
    cv::bitwise_and(eyeROIrgb, mask, corners);
    std::vector<cv::Mat>  maskChannels = std::vector<cv::Mat>();
    cv::split(corners, maskChannels);
    double cornerPixelTotal = cv::countNonZero(maskChannels[0]);
    NSLog(@"cv::countNonZero(maskChannels[0]): %d, maskChannels[0].total(): %zu, ratio: %f", cv::countNonZero(maskChannels[0]), maskChannels[0].total(), (double)cv::countNonZero(maskChannels[0]) / (double)maskChannels[0].total());
    NSLog(@"cv::countNonZero(maskChannels[1]): %d, maskChannels[1].total(): %zu, ratio: %f", cv::countNonZero(maskChannels[1]), maskChannels[1].total(), (double)cv::countNonZero(maskChannels[1]) / (double)maskChannels[1].total());
    NSLog(@"cv::countNonZero(maskChannels[2]): %d, maskChannels[2].total(): %zu, ratio: %f", cv::countNonZero(maskChannels[2]), maskChannels[2].total(), (double)cv::countNonZero(maskChannels[2]) / (double)maskChannels[2].total());
    
    // convert RGB corners to HSV and split into channels
    cv::Mat cornersHSV;
    cv::cvtColor(corners ,cornersHSV , CV_RGB2HSV);
    std::vector<cv::Mat>  cornerChannels = std::vector<cv::Mat>();
    cv::split(cornersHSV, cornerChannels);
    cv::Mat cornersHue = cornerChannels[0];
    cv::Mat cornersSat = cornerChannels[1];
    cv::Mat cornersVal = cornerChannels[2];
    
    /*
     for(int y = 0; y< self.size.height; y++) {
     for(int x=0; x<self.size.width; x++) {
     NSLog(@"(%d,%d) h=%d s=%d v=%d)", x, y, cornersHue.at<UTF8Char>(y, x), cornersSat.at<UTF8Char>(y, x), cornersVal.at<UTF8Char>(y, x));
     }
     }
     */
    
    // filter the Hue channel for values in the upper wheel red area 0..15
    int avgCornerVal = 0;
    //cv::inRange(cornersHue, cv::Scalar(0), cv::Scalar(lowerWheelMax), cornersHue);
    cv::inRange(cornersHue, cv::Scalar(0), cv::Scalar(30), cornersHue);
    NSLog(@"cv::countNonZero(cornersHue): %d, cornersHue.total(): %zu, ratio: %f", cv::countNonZero(cornersHue), cornersHue.total(), (double)cv::countNonZero(cornersHue) / (double)cornersHue.total());
    
    /*
     for(int y = 0; y< self.size.height; y++) {
     for(int x=0; x<self.size.width; x++) {
     NSLog(@"(%d,%d) h=%d v=%d)", x, y, cornersHue.at<UTF8Char>(y, x), cornersVal.at<UTF8Char>(y, x));
     }
     }
     */
    
    cv::bitwise_and(cornersHue, cornersSat, cornersSat);
    int avgCornerSat = 0;
    if ((double)cv::countNonZero(cornersSat) / cornerPixelTotal > minSkinRatio) {
        // get avg of non zero values of skin pixels with red hue
        avgCornerSat = (cv::countNonZero(cornersSat) > 0)?cv::sum(cornersSat).val[0]/cv::countNonZero(cornersSat):0;
    }
    
    NSLog(@"cv::sum(cornersSat).val[0]: %f, cv::countNonZero(cornersSat): %d, avgCornerSat: %d", cv::sum(cornersSat).val[0], cv::countNonZero(cornersSat), avgCornerSat);
    
    // zero out the values for pixels that are outside the target hues of 0..15
    cv::bitwise_and(cornersHue, cornersVal, cornersVal);
    NSLog(@"cv::countNonZero(cornersVal): %d", cv::countNonZero(cornersVal));
    
    /*
     for(int y = 0; y< self.size.height; y++) {
     for(int x=0; x<self.size.width; x++) {
     NSLog(@"(%d,%d) %d)", x, y, cornersVal.at<UTF8Char>(y, x));
     }
     }
     */
    
    if ((double)cv::countNonZero(cornersVal) / (double)cornersVal.total() > minSkinRatio) {
        // get avg of non zero values of skin pixels with red hue
        avgCornerVal = (cv::countNonZero(cornersVal) > 0)?cv::sum(cornersVal).val[0]/cv::countNonZero(cornersVal):0;
    }
    NSLog(@"cv::sum(cornersVal).val[0]: %f, cv::countNonZero(cornersVal): %d, ratio: %f, avgCornerVal: %d", cv::sum(cornersVal).val[0], cv::countNonZero(cornersVal), (double)cv::countNonZero(cornersVal) / (double)cornersVal.total(), avgCornerVal);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();
    
    cv::split(eyeROIhsv, channels);
    
    cv::Mat hue = channels[0];
    cv::Mat sat = channels[1];
    cv::Mat val = channels[2];
    
    cv::Mat redLowerWheel;
    cv::Mat redUpperWheel;
    
    cv::inRange(hue, cv::Scalar(0), cv::Scalar(lowerWheelMax), redLowerWheel);
    
    /*
    if (avgCornerVal > 0) {
        NSLog(@"cv::countNonZero(val): %d", cv::countNonZero(val));
        cv::Scalar maxValThresh = cv::Scalar(avgCornerVal*skinValMultiplier);
        cv::inRange(val, cv::Scalar(0), maxValThresh, val);
        NSLog(@"maxValThresh.val[0]: %f, cv::countNonZero(val): %d", maxValThresh.val[0], cv::countNonZero(val));
        cv::bitwise_and(redLowerWheel, val, redLowerWheel);
    }
    */
    if (avgCornerSat > 0) {
        NSLog(@"cv::countNonZero(sat): %d", cv::countNonZero(sat));
        cv::Scalar minSatThresh = cv::Scalar(avgCornerSat*1.35);
        cv::inRange(sat, minSatThresh, cv::Scalar(255), sat);
        NSLog(@"minSatThresh.val[0]: %f, cv::countNonZero(sat): %d", minSatThresh.val[0], cv::countNonZero(sat));
        cv::bitwise_and(redLowerWheel, sat, redLowerWheel);
    }

    cv::inRange(hue, cv::Scalar(upperWheelMin), cv::Scalar(179), redUpperWheel);
    cv::max(redLowerWheel, redUpperWheel, hue);
    
    if (process == 0) {
        return [[UIImage alloc] initWithCVMat:hue.clone()];
    }
    
    cv::equalizeHist(hue, hue);
    if (process == 1) {
        return [[UIImage alloc] initWithCVMat:hue.clone()];
    }
    
    cv::GaussianBlur(hue, hue, cv::Size(3.0, 3.0), 0);
    if (process == 2) {
        return [[UIImage alloc] initWithCVMat:hue.clone()];
    }
    
    cv::threshold(hue, hue, thresh, 255, cv::THRESH_BINARY);
    if (process == 3) {
        return [[UIImage alloc] initWithCVMat:hue.clone()];
    }
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(hue, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        cv::rectangle(eyeROIrgb, rect, cv::Scalar(0,255,255), 0);
        NSLog(@"[%d x %d] %f", rect.width, rect.height, std::abs(1 - ((double)rect.width / (double)rect.height)));
        NSLog(@"contour area: %f, bounding rect area: %f, %f", area, (double)rect.width*(double)rect.height, area/((double)rect.width*(double)rect.height));
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < ratio * self.size.width * self.size.height
            && area/((double)rect.width*(double)rect.height) > 0.33) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    
    
    
    
    if (!largestContour.empty()){
        cv::Point2f center = cv::Point2f(0,0);
        float radius = 0;
        cv::minEnclosingCircle(largestContour, center, radius);
        cv::circle(eyeROIrgb, center, radius, cv::Scalar(0,255,0));
        
        std::vector<std::vector<cv::Point> > arrayOfLargestContour(1);
        arrayOfLargestContour[0] = largestContour;
        cv::drawContours(eyeROIrgb, arrayOfLargestContour, 0, cv::Scalar(0,255,0));
        
        CvRect boundingRect = cv::boundingRect(largestContour);
        NSLog(@"largest Contour [%d x %d] %f", boundingRect.width, boundingRect.height, std::abs(1 - ((double)boundingRect.width / (double)boundingRect.height)));
        
        std::vector<cv::Point2f>  contourF;
        cv::Mat(largestContour).copyTo(contourF);
        cv::Mat(largestContour).convertTo(contourF, cv::Mat(contourF).type());
        
        UInt32 insideResults [9] = {0,0,0,0,0,0,0,0,0};
        UInt32 outsideResults [9] = {0,0,0,0,0,0,0,0,0};
        
        for(int y = boundingRect.y; y < boundingRect.y + boundingRect.height; y++) {
            for(int x = boundingRect.x; x < boundingRect.x + boundingRect.width; x++) {
                if (isPointInCircle(center.x, center.y, radius, x, y)) {
                    cv::Point p = cv::Point(x, y);
                    cv::Vec3b pixel = eyeROIhsv.at<cv::Vec3b>(y, x);
                    //NSLog(@"pixel(%d, %d) = (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                    if (cv::pointPolygonTest(contourF, p, false) >= 0) {
                        //NSLog(@"pixel In Contour (%d, %d) = (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                        if (pixel.val[0] >= 0 && pixel.val[0] <= 30) {
                            insideResults[0] += pixel.val[0];
                            insideResults[1] += pixel.val[1];
                            insideResults[2] += pixel.val[2];
                            insideResults[3] += 1;
                        } else if (pixel.val[0] >= 150 && pixel.val[0] <= 179) {
                            insideResults[4] += pixel.val[0];
                            insideResults[5] += pixel.val[1];
                            insideResults[6] += pixel.val[2];
                            insideResults[7] += 1;
                        } else {
                            insideResults[8] += 1;
                        }
                        
                    } else {
                        //NSLog(@"pixel Outside Contour (%d, %d) = (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                        if (pixel.val[0] >= 0 && pixel.val[0] <= 30) {
                            outsideResults[0] += pixel.val[0];
                            outsideResults[1] += pixel.val[1];
                            outsideResults[2] += pixel.val[2];
                            outsideResults[3] += 1;
                        } else if (pixel.val[0] >= 150 && pixel.val[0] <= 179) {
                            outsideResults[4] += pixel.val[0];
                            outsideResults[5] += pixel.val[1];
                            outsideResults[6] += pixel.val[2];
                            outsideResults[7] += 1;
                        }else {
                            outsideResults[8] += 1;
                        }
                        
                    }
                }
            }
        }
        NSLog(@"inside 0..30: h=%d (%d), s=%d (%d), v=%d (%d), t=%d", insideResults[0], insideResults[0]/insideResults[3], insideResults[1], insideResults[1]/insideResults[3] , insideResults[2], insideResults[2]/insideResults[3], insideResults[3]);
        NSLog(@"inside 150..179: h=%d (%d), s=%d (%d), v=%d (%d), t=%d", insideResults[4], insideResults[4]/insideResults[7], insideResults[5], insideResults[5]/insideResults[7] , insideResults[6], insideResults[6]/insideResults[7], insideResults[7]);
        NSLog(@"inside 31..149: t=%d", insideResults[8]);
        
        NSLog(@"outside 0..30: h=%d (%d), s=%d (%d), v=%d (%d), t=%d", outsideResults[0], outsideResults[0]/outsideResults[3], outsideResults[1], outsideResults[1]/outsideResults[3] , outsideResults[2], outsideResults[2]/outsideResults[3], outsideResults[3]);
        NSLog(@"outside 150..179: h=%d (%d), s=%d (%d), v=%d (%d), t=%d", outsideResults[4], outsideResults[4]/outsideResults[7], outsideResults[5], outsideResults[5]/outsideResults[7] , outsideResults[6], outsideResults[6]/outsideResults[7], outsideResults[7]);
        NSLog(@"outside 31..149: t=%d", outsideResults[8]);
        
    }
    cv::circle(eyeROIrgb, cv::Point2f(self.size.width/2, self.size.height/2), self.size.width/2, cv::Scalar(0,0,0));
    cv::Mat eyeROIrgba;
    cv::cvtColor(eyeROIrgb , eyeROIrgba, CV_RGB2RGBA);
    return [[UIImage alloc] initWithCVMat:eyeROIrgba.clone()];
}


/*
-(UIImage *)CVAfterPrcocessID:(int)process withUpperWheelMin:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax withMinSkinRatio:(float)minSkinRatio withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier
{
    cv::Mat eyeROIrgb = [self CVMat3];
    cv::Mat eyeROIhsv; // = eyeROIrgb.clone();
    
    cv::cvtColor(eyeROIrgb ,eyeROIhsv , CV_RGB2HSV);
    
    cv::Mat reverseMask(eyeROIrgb.size(), eyeROIrgb.type());
    reverseMask.setTo(cv::Scalar(0, 0, 0));
    cv::circle(reverseMask, cv::Point2f(self.size.width/2, self.size.height/2), self.size.width/2, cv::Scalar(255, 255, 255), -1, 8, 0);
    
    // create corners image from masked RGB image
    cv::Mat innerCircle;
    cv::bitwise_and(eyeROIrgb, reverseMask, innerCircle);
    
    // convert RGB corners to HSV and split into channels
    cv::Mat innerCircleHSV;
    cv::cvtColor(innerCircle , innerCircleHSV , CV_RGB2HSV);
    std::vector<cv::Mat>  innerCircleChannels = std::vector<cv::Mat>();
    cv::split(innerCircleHSV, innerCircleChannels);
    cv::Mat innerCircleHue = innerCircleChannels[0];
    cv::Mat innerCircleSat = innerCircleChannels[1];
    cv::Mat innerCircleVal = innerCircleChannels[2];
    
    cv::inRange(innerCircleHue, cv::Scalar(0), cv::Scalar(30), innerCircleHue);
    
    cv::bitwise_and(innerCircleHue, innerCircleSat, innerCircleSat);
    int avgInnerCircleSat = (cv::countNonZero(innerCircleSat) > 0)?cv::sum(innerCircleSat).val[0]/cv::countNonZero(innerCircleSat):0;
    NSLog(@"cv::sum(innerCircleSat).val[0]: %f, cv::countNonZero(innerCircleSat): %d, avgInnerCircleSat: %d", cv::sum(innerCircleSat).val[0], cv::countNonZero(innerCircleSat), avgInnerCircleSat);

    cv::bitwise_and(innerCircleHue, innerCircleVal, innerCircleVal);
    int avgInnerCircleVal = (cv::countNonZero(innerCircleVal) > 0)?cv::sum(innerCircleVal).val[0]/cv::countNonZero(innerCircleVal):0;
    NSLog(@"cv::sum(innerCircleVal).val[0]: %f, cv::countNonZero(innerCircleVal): %d, avgInnerCircleVal: %d", cv::sum(innerCircleVal).val[0], cv::countNonZero(innerCircleVal), avgInnerCircleVal);
    
    
    
    // create mask image with black circle to mask eye area and expose the skin for pixel analysis
    cv::Mat mask(eyeROIrgb.size(), eyeROIrgb.type());
    mask.setTo(cv::Scalar(255, 255, 255));
    cv::circle(mask, cv::Point2f(self.size.width/2, self.size.height/2), self.size.width/2, cv::Scalar(0, 0, 0), -1, 8, 0);
    
    // create corners image from masked RGB image
    cv::Mat corners;
    cv::bitwise_and(eyeROIrgb, mask, corners);
    
    // convert RGB corners to HSV and split into channels
    cv::Mat cornersHSV;
    cv::cvtColor(corners ,cornersHSV , CV_RGB2HSV);
    std::vector<cv::Mat>  cornerChannels = std::vector<cv::Mat>();
    cv::split(cornersHSV, cornerChannels);
    cv::Mat cornersHue = cornerChannels[0];
    cv::Mat cornersSat = cornerChannels[1];
    cv::Mat cornersVal = cornerChannels[2];
    

    
    // filter the Hue channel for values in the upper wheel red area 0..15
    int avgCornerVal = 0;
    //cv::inRange(cornersHue, cv::Scalar(0), cv::Scalar(lowerWheelMax), cornersHue);
    cv::inRange(cornersHue, cv::Scalar(0), cv::Scalar(30), cornersHue);
    NSLog(@"cv::countNonZero(cornersHue): %d, cornersHue.total(): %zu, ratio: %f", cv::countNonZero(cornersHue), cornersHue.total(), (double)cv::countNonZero(cornersHue) / (double)cornersHue.total());


    cv::bitwise_and(cornersHue, cornersSat, cornersSat);
    int avgCornerSat = (cv::countNonZero(cornersSat) > 0)?cv::sum(cornersSat).val[0]/cv::countNonZero(cornersSat):0;
    NSLog(@"cv::sum(cornersSat).val[0]: %f, cv::countNonZero(cornersSat): %d, avgCornerSat: %d", cv::sum(cornersSat).val[0], cv::countNonZero(cornersSat), avgCornerSat);
    
    // zero out the values for pixels that are outside the target hues of 0..15
    cv::bitwise_and(cornersHue, cornersVal, cornersVal);
    NSLog(@"cv::countNonZero(cornersVal): %d", cv::countNonZero(cornersVal));
    

    
    if ((double)cv::countNonZero(cornersVal) / (double)cornersVal.total() > minSkinRatio) {
        // get avg of non zero values of skin pixels with red hue
        avgCornerVal = (cv::countNonZero(cornersVal) > 0)?cv::sum(cornersVal).val[0]/cv::countNonZero(cornersVal):0;
    }
    NSLog(@"cv::sum(cornersVal).val[0]: %f, cv::countNonZero(cornersVal): %d, ratio: %f, avgCornerVal: %d", cv::sum(cornersVal).val[0], cv::countNonZero(cornersVal), (double)cv::countNonZero(cornersVal) / (double)cornersVal.total(), avgCornerVal);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();
    
    cv::split(eyeROIhsv, channels);
    
    cv::Mat hue = channels[0];
    cv::Mat sat = channels[1];
    cv::Mat val = channels[2];
    
    cv::Mat redLowerWheel;
    cv::Mat redUpperWheel;
    
    cv::inRange(hue, cv::Scalar(0), cv::Scalar(lowerWheelMax), redLowerWheel);
    if (avgCornerVal > 0) {
        NSLog(@"cv::countNonZero(val): %d", cv::countNonZero(val));
        cv::Scalar maxValThresh = cv::Scalar(avgCornerVal*skinValMultiplier);
        cv::inRange(val, cv::Scalar(0), maxValThresh, val);
        NSLog(@"maxValThresh.val[0]: %f, cv::countNonZero(val): %d", maxValThresh.val[0], cv::countNonZero(val));
        cv::bitwise_and(redLowerWheel, val, redLowerWheel);
    }
    NSLog(@"cv::countNonZero(sat): %d", cv::countNonZero(sat));
    cv::Scalar minSatThresh = cv::Scalar(avgCornerSat*1.5);
    cv::inRange(sat, minSatThresh, cv::Scalar(255), sat);
    NSLog(@"minSatThresh.val[0]: %f, cv::countNonZero(sat): %d", minSatThresh.val[0], cv::countNonZero(sat));
    cv::bitwise_and(redLowerWheel, sat, redLowerWheel);
    
    
    cv::inRange(hue, cv::Scalar(upperWheelMin), cv::Scalar(179), redUpperWheel);
    cv::max(redLowerWheel, redUpperWheel, hue);
    
    if (process == 0) {
        return [[UIImage alloc] initWithCVMat:hue.clone()];
    }
    
    cv::equalizeHist(hue, hue);
    if (process == 1) {
        return [[UIImage alloc] initWithCVMat:hue.clone()];
    }
    
    cv::GaussianBlur(hue, hue, cv::Size(3.0, 3.0), 0);
    if (process == 2) {
        return [[UIImage alloc] initWithCVMat:hue.clone()];
    }
    
    cv::threshold(hue, hue, thresh, 255, cv::THRESH_BINARY);
    if (process == 3) {
        return [[UIImage alloc] initWithCVMat:hue.clone()];
    }
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(hue, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        cv::rectangle(eyeROIrgb, rect, cv::Scalar(0,255,255), 0);
        NSLog(@"%f", std::abs(1 - ((double)rect.width / (double)rect.height)));
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < ratio * self.size.width * self.size.height) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    

    
    
    if (!largestContour.empty()){
        cv::Point2f center = cv::Point2f(0,0);
        float radius = 0;
        cv::minEnclosingCircle(largestContour, center, radius);
        cv::circle(eyeROIrgb, center, radius, cv::Scalar(0,255,0));
        
        std::vector<std::vector<cv::Point> > arrayOfLargestContour(1);
        arrayOfLargestContour[0] = largestContour;
        cv::drawContours(eyeROIrgb, arrayOfLargestContour, 0, cv::Scalar(0,255,0));
        
        CvRect boundingRect = cv::boundingRect(largestContour);
        
        std::vector<cv::Point2f>  contourF;
        cv::Mat(largestContour).copyTo(contourF);
        cv::Mat(largestContour).convertTo(contourF, cv::Mat(contourF).type());

        UInt32 insideResults [9] = {0,0,0,0,0,0,0,0,0};
        UInt32 outsideResults [9] = {0,0,0,0,0,0,0,0,0};

        for(int y = boundingRect.y; y < boundingRect.y + boundingRect.height; y++) {
            for(int x = boundingRect.x; x < boundingRect.x + boundingRect.width; x++) {
                if (isPointInCircle(center.x, center.y, radius, x, y)) {
                    cv::Point p = cv::Point(x, y);
                    cv::Vec3b pixel = eyeROIhsv.at<cv::Vec3b>(y, x);
                    //NSLog(@"pixel(%d, %d) = (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                    if (cv::pointPolygonTest(contourF, p, false) >= 0) {
                        //NSLog(@"pixel In Contour (%d, %d) = (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                        if (pixel.val[0] >= 0 && pixel.val[0] <= 30) {
                            insideResults[0] += pixel.val[0];
                            insideResults[1] += pixel.val[1];
                            insideResults[2] += pixel.val[2];
                            insideResults[3] += 1;
                        } else if (pixel.val[0] >= 150 && pixel.val[0] <= 179) {
                            insideResults[4] += pixel.val[0];
                            insideResults[5] += pixel.val[1];
                            insideResults[6] += pixel.val[2];
                            insideResults[7] += 1;
                        } else {
                            insideResults[8] += 1;
                        }

                    } else {
                        //NSLog(@"pixel Outside Contour (%d, %d) = (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                        if (pixel.val[0] >= 0 && pixel.val[0] <= 30) {
                            outsideResults[0] += pixel.val[0];
                            outsideResults[1] += pixel.val[1];
                            outsideResults[2] += pixel.val[2];
                            outsideResults[3] += 1;
                        } else if (pixel.val[0] >= 150 && pixel.val[0] <= 179) {
                            outsideResults[4] += pixel.val[0];
                            outsideResults[5] += pixel.val[1];
                            outsideResults[6] += pixel.val[2];
                            outsideResults[7] += 1;
                        }else {
                            outsideResults[8] += 1;
                        }

                    }
                }
            }
        }
        NSLog(@"inside 0..30: h=%d (%d), s=%d (%d), v=%d (%d), t=%d", insideResults[0], insideResults[0]/insideResults[3], insideResults[1], insideResults[1]/insideResults[3] , insideResults[2], insideResults[2]/insideResults[3], insideResults[3]);
        NSLog(@"inside 150..179: h=%d (%d), s=%d (%d), v=%d (%d), t=%d", insideResults[4], insideResults[4]/insideResults[7], insideResults[5], insideResults[5]/insideResults[7] , insideResults[6], insideResults[6]/insideResults[7], insideResults[7]);
        NSLog(@"inside 31..149: t=%d", insideResults[8]);
        
        NSLog(@"outside 0..30: h=%d (%d), s=%d (%d), v=%d (%d), t=%d", outsideResults[0], outsideResults[0]/outsideResults[3], outsideResults[1], outsideResults[1]/outsideResults[3] , outsideResults[2], outsideResults[2]/outsideResults[3], outsideResults[3]);
        NSLog(@"outside 150..179: h=%d (%d), s=%d (%d), v=%d (%d), t=%d", outsideResults[4], outsideResults[4]/outsideResults[7], outsideResults[5], outsideResults[5]/outsideResults[7] , outsideResults[6], outsideResults[6]/outsideResults[7], outsideResults[7]);
        NSLog(@"outside 31..149: t=%d", outsideResults[8]);
        
    }
    cv::circle(eyeROIrgb, cv::Point2f(self.size.width/2, self.size.height/2), self.size.width/2, cv::Scalar(0,0,0));
    cv::Mat eyeROIrgba;
    cv::cvtColor(eyeROIrgb , eyeROIrgba, CV_RGB2RGBA);
    return [[UIImage alloc] initWithCVMat:eyeROIrgba.clone()];
}
*/


-(UIImage *)CVRedHueMat
{
    cv::Mat eyeROIrgb = [self CVMat3];
    NSLog(@"eyeROIrgb type: %d", eyeROIrgb.type());
    cv::Mat eyeROIhsv = eyeROIrgb.clone();
    
    //cv::cvtColor(eyeROI , result , CV_RGBA2RGB);
    //NSLog(@"type: %d", result.type());
    cv::cvtColor(eyeROIrgb ,eyeROIhsv , CV_RGB2HSV);
    NSLog(@"eyeROIhsv type: %d", eyeROIhsv.type());
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();
    
    cv::split(eyeROIhsv, channels);
    
    cv::Mat hue = channels[0];
    cv::Mat sat = channels[1];
    cv::Mat val = channels[2];
    
    cv::Mat redLowerWheel = hue.clone();
    cv::Mat redUpperWheel = hue.clone();
    cv::inRange(hue, cv::Scalar(0), cv::Scalar(15), redLowerWheel);
    NSLog(@"\nRed Lower Wheel\n");
    for(int y = 0; y< self.size.height; y++) {
        for(int x=0; x<self.size.width; x++) {
            if (redLowerWheel.at<UTF8Char>(y, x) > 0) {
                NSLog(@"(%d,%d) h=%d)", x, y, redLowerWheel.at<UTF8Char>(y, x));
            }
            
        }
    }
    cv::inRange(hue, cv::Scalar(165), cv::Scalar(179), redUpperWheel);
    
    NSLog(@"\nRed Upper Wheel\n");
    for(int y = 0; y< self.size.height; y++) {
        for(int x=0; x<self.size.width; x++) {
            if (redUpperWheel.at<UTF8Char>(y, x) > 0) {
                NSLog(@"(%d,%d) h=%d)", x, y, redUpperWheel.at<UTF8Char>(y, x));
            }
        }
    }
    
    cv::max(redLowerWheel, redUpperWheel, hue);
    
    NSLog(@"\nHue\n");
    for(int y = 0; y< self.size.height; y++) {
        for(int x=0; x<self.size.width; x++) {
            if (hue.at<UTF8Char>(y, x) > 0) {
                NSLog(@"(%d,%d) h=%d)", x, y, hue.at<UTF8Char>(y, x));
            }
        }
    }
    
    cv::merge(channels, eyeROIhsv);
    
    /*
    cv::Scalar lower_red = cv::Scalar(0, 0, 0);
    cv::Scalar upper_red = cv::Scalar(10, 255, 255);
    cv::inRange(result, lower_red, upper_red, result);
    NSLog(@"type: %d", result.type());
    [self CVLog:result withRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    */
    
    cv::equalizeHist(hue, hue);
    cv::GaussianBlur(hue, hue, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(hue, hue, 200, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(hue, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    cv::drawContours(eyeROIrgb, contours, 0, cv::Scalar(0,255,255));
    while (itc!=contours.end()) {
        cv::Rect rect = cv::boundingRect(*itc);
        cv::rectangle(eyeROIrgb, rect, cv::Scalar(0,255,255), 0);
        ++itc;
    }
    cv::Mat eyeROIrgba;
    cv::cvtColor(eyeROIrgb , eyeROIrgba, CV_RGB2RGBA);
    return [[UIImage alloc] initWithCVMat:eyeROIrgba.clone()];

    
    
    //return [[UIImage alloc] initWithCVMat:eyeROIhsv.clone()];
}



- (cv::Mat)CVMat4:(cv::Mat)src
{
    cv::Mat dst;
    cv::cvtColor(src , dst, CV_RGB2RGBA);
    return dst;
    
}

-(cv::Mat)CVGrayscaleMat
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (cv::Mat)CVFilterGB:(cv::Mat)dst withGreenChanels:(cv::Mat)greenChannels withScalar:(UTF8Char)maxGreenValue
         withBlueChanels:(cv::Mat)blueChannels withScalar:(UTF8Char)maxBlueValue withRect:(CGRect)rect
{
    //cv::Mat result = src.clone();
    for(int y = 0; y< rect.size.height; y++) {
        for(int x=0; x<rect.size.width; x++) {
            //UTF8Char srcChannel = src.at<UTF8Char>(y, x);
            //UTF8Char cmpChannel = cmp.at<UTF8Char>(y, x);
            if (greenChannels.at<UTF8Char>(y, x) > maxGreenValue || blueChannels.at<UTF8Char>(y, x) > maxBlueValue) {
                dst.at<UTF8Char>(y, x) = 0;
            }
            //if (src.at<UTF8Char>(y, x) > 0) {
            //    NSLog(@"red=%d, cmp=%d, result=%d", src.at<UTF8Char>(y, x), cmp.at<UTF8Char>(y, x), result.at<UTF8Char>(y, x));
            //}
        }
    }
    return dst.clone();
}

- (void)CVLog:(cv::Mat)src withRect:(CGRect)rect
{
    for(int y = 0; y< rect.size.height; y++) {
        for(int x=0; x<rect.size.width; x++) {
            cv::Vec3b pixel = src.at<cv::Vec3b>(y, x);
            NSLog(@"(%d,%d) h=%d, s=%d, v=%d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
        }
    }
}


- (void)CVLog:(cv::Mat)rgb withHSV:(cv::Mat)hsv withRect:(CGRect)rect
{
    for(int y = 0; y< rect.size.height; y++) {
        for(int x=0; x<rect.size.width; x++) {
            cv::Vec3b rgbPixel = rgb.at<cv::Vec3b>(y, x);
            cv::Vec3b hsvPixel = hsv.at<cv::Vec3b>(y, x);
            NSLog(@"(%d,%d) (%d,%d,%d) (%d,%d,%d)", x, y, rgbPixel.val[0], rgbPixel.val[1], rgbPixel.val[2], hsvPixel.val[0], hsvPixel.val[1], hsvPixel.val[2]);
        }
    }
}


-(UIImage *)CVBlurredMat
{
    cv::Mat result = [self CVMat];
    cv::cvtColor(result , result , CV_RGBA2GRAY);
    //cv::Canny(result, result, 5, 70, 3);
    
    cv::Size s(9,9);
    cv::GaussianBlur(result, result, s, 7, 7);
    return [[UIImage alloc] initWithCVMat:result];
}

-(UIImage *)CVBilateralFilterMat:(int)pixelDiameter
                withSigmaColor:(int)sigmaColor
                  withSigmaSpace:(int)sigmaSpace
{
    cv::Mat result = [self CVMat];
    cv::cvtColor(result , result , CV_RGBA2GRAY);
    cv::Mat bilateralResult;
    cv::bilateralFilter(result, bilateralResult, pixelDiameter, sigmaColor, sigmaSpace);
    
    return [[UIImage alloc] initWithCVMat:bilateralResult];
}

-(UIImage *)CVFindCirclesMat
{
    cv::Mat result = [self CVMat];
    cv::cvtColor(result , result , CV_RGBA2GRAY);
    //cv::Canny(result, result, 5, 70, 3);

    cv::Size s(9,9);
    cv::GaussianBlur(result, result, s, 7, 7);
    
    std::vector<cv::Vec3f> circles;
    
    cv::HoughCircles(result, circles, CV_HOUGH_GRADIENT, 2, 32.0, 30, 550, 0, 0);
    
    NSLog(@"Circles.count: %lu in rectangle: %fx%f", circles.size(), self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, self.size.width, self.size.height), self.CGImage);
    CGContextSetStrokeColorWithColor(context,[UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 5.0);
    CGContextStrokeRect(context, CGRectMake(0.0, 0.0, self.size.width, self.size.height));
    CGContextStrokePath(context);
    for (size_t i = 0; i < circles.size(); i++) {
        cv::Vec3i circle = circles[i];
        //CGFloat startAngle = CGFloat(2 * M_PI);
        //CGFloat endAngle = 0.0;
        
        
        CGContextSetFillColorWithColor(context,[UIColor yellowColor].CGColor);
        // Draw the arc around the circle
        CGContextAddArc(context, CGFloat(circle[0]), CGFloat(circle[1]), CGFloat(circle[2]), -(float)M_PI, (float)M_PI, 0);
        //CGContextAddArc(context, self.size.width/2, self.size.height/2, self.size.height/8, CGFloat(2 * M_PI), CGFloat(0.0), 0);
        // Draw the arc
        CGContextDrawPath(context, kCGPathStroke);
        //CGContextStrokePath(context);
        NSLog(@"Circle x: %d, y: %d r: %d Found in rectangle: %fx%f", circle[0], circle[1], circle[2], self.size.width, self.size.height);
    }
    //CGContextAddArc(context, self.size.width/4, self.size.height/4, 16, -(float)M_PI, (float)M_PI, 0);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.size.width, self.size.height);
    CGContextMoveToPoint(context, self.size.width, 0);
    CGContextAddLineToPoint(context, 0, self.size.height);
    CGContextStrokePath(context);
    
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}



-(UIImage *)CVOutlineCirclesMat:(int)inverseRatioResolution withMinDistBetweenCenters:(int)minDistBetweenCenters
            withUpperCannyEdgeThreshold:(int)upperCannyEdgeThreshold
            withCenterDetectionThreshold:(int)centerDetectionThreshold
            withMinRadiusToDetect:(int)minRadiusToDetect
            withMaxRadiusToDetect:(int)maxRadiusToDetect
            withGaussianKernelWidth:(int)gaussianKernelWidth
            withGaussianKernelHeight:(int)gaussianKernelHeight
            withGaussianSigmaX:(int)gaussianSigmaX
            withGaussianSigmaY:(int)gaussianSigmaY
{
    cv::Mat result = [self CVMat];
    cv::cvtColor(result , result , CV_RGBA2GRAY);
    cv::Size s(gaussianKernelWidth,gaussianKernelHeight);
    //cv::GaussianBlur(result, result, s, gaussianSigmaX, gaussianSigmaY);
    cv::Mat bilateralResult;
    cv::bilateralFilter(result, bilateralResult, 9, 75, 75);
    
    std::vector<cv::Vec3f> circles;
    
    //cv::HoughCircles(result, circles, CV_HOUGH_GRADIENT, inverseRatioResolution, minDistBetweenCenters, upperCannyEdgeThreshold, centerDetectionThreshold, minRadiusToDetect, maxRadiusToDetect);
    cv::HoughCircles(bilateralResult, circles, CV_HOUGH_GRADIENT, inverseRatioResolution, minDistBetweenCenters, upperCannyEdgeThreshold, centerDetectionThreshold, minRadiusToDetect, maxRadiusToDetect);
    
    NSLog(@"Circles.count: %lu in rectangle: %fx%f", circles.size(), self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, self.size.width, self.size.height), self.CGImage);
    CGContextSetStrokeColorWithColor(context,[UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 5.0);
    //CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextStrokeRect(context, CGRectMake(0.0, 0.0, self.size.width, self.size.height));
    CGContextStrokePath(context);
    for (size_t i = 0; i < circles.size(); i++) {
        cv::Vec3i circle = circles[i];
        //CGFloat startAngle = CGFloat(2 * M_PI);
        //CGFloat endAngle = 0.0;


        CGContextSetFillColorWithColor(context,[UIColor yellowColor].CGColor);
        // Draw the arc around the circle
        CGContextAddArc(context, CGFloat(circle[0]), CGFloat(circle[1]), CGFloat(circle[2]), -(float)M_PI, (float)M_PI, 0);
        //CGContextAddArc(context, self.size.width/2, self.size.height/2, self.size.height/8, CGFloat(2 * M_PI), CGFloat(0.0), 0);
        // Draw the arc
        CGContextDrawPath(context, kCGPathStroke);
        //CGContextStrokePath(context);
        NSLog(@"Circle x: %d, y: %d r: %d Found in rectangle: %fx%f", circle[0], circle[1], circle[2], self.size.width, self.size.height);
    }
    //CGContextAddArc(context, self.size.width/4, self.size.height/4, 16, -(float)M_PI, (float)M_PI, 0);
    //CGContextRestoreGState(context);
    
    /*
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.size.width, self.size.height);
    CGContextMoveToPoint(context, self.size.width, 0);
    CGContextAddLineToPoint(context, 0, self.size.height);
    CGContextStrokePath(context);
    */
    
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

/*
- (UIImage*)CVGetDebugMat:(CGRect)eye
{
    cv::Mat rgbaMat = [self CVMat];
    
    
    //cv::Rect roi = cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height);
    //cv::Mat eye_roi = src(roi).clone();
    //return [[UIImage alloc] initWithCVMat:eye_roi];
    
    
    cv::Mat rgbMat = [self CVMat3];
    
    
    cv::Mat debugMat = cv::Mat();
    rgbMat.copyTo(debugMat);
    return [[UIImage alloc] initWithCVMat:debugMat];
}
*/

/*
- (UIImage*)CVGetRedMat:(CGRect)eye
{
    //cv::Mat rgbaMat = [self CVMat];
    cv::Mat rgbMat = [self CVMat3];
    
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    cv::Mat debugMat = cv::Mat();
    eyeROIMat.copyTo(debugMat);
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);
    //cv::Mat channels = cv::Mat();
    cv::split(eyeROIMat, channels);
    //cv::Point p = cv::Point();
    
    for(int y = 0; y < 3; y++) {
        //p.y = y;
        for(int x = 0; x < 3; x++) {
            //p.x = x;
            cv::Vec3b pixel = eyeROIMat.at<cv::Vec3b>(y, x);
            NSLog(@"eyeROIMat: %d, %d pixel: (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
        }
    }

    cv::Mat red = channels[0];
    for(int y = 0; y < 3; y++) {
        //p.y = y;
        for(int x = 0; x < 3; x++) {
            //p.x = x;
            cv::Vec3b pixel = red.at<cv::Vec3b>(y, x);
            NSLog(@"red: %d, %d pixel: (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
        }
    }
    cv::Mat green = channels[1];
    for(int y = 0; y < 3; y++) {
        //p.y = y;
        for(int x = 0; x < 3; x++) {
            //p.x = x;
            cv::Vec3b pixel = green.at<cv::Vec3b>(y, x);
            NSLog(@"green: %d, %d pixel: (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
        }
    }
    cv::Mat blue = channels[2];
    for(int y = 0; y < 3; y++) {
        //p.y = y;
        for(int x = 0; x < 3; x++) {
            //p.x = x;
            cv::Vec3b pixel = blue.at<cv::Vec3b>(y, x);
            NSLog(@"blue: %d, %d pixel: (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
        }
    }
    
    cv::subtract(red, green, red);
    for(int y = 0; y < 3; y++) {
        //p.y = y;
        for(int x = 0; x < 3; x++) {
            //p.x = x;
            cv::Vec3b pixel = red.at<cv::Vec3b>(y, x);
            NSLog(@"red-green: %d, %d pixel: (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
        }
    }
    
    cv::subtract(red, blue, red);
    for(int y = 0; y < 3; y++) {
        //p.y = y;
        for(int x = 0; x < 3; x++) {
            //p.x = x;
            cv::Vec3b pixel = red.at<cv::Vec3b>(y, x);
            NSLog(@"red-blue: %d, %d pixel: (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
        }
    }
    
    return [[UIImage alloc] initWithCVMat:red.clone()];
}

- (UIImage*)CVGetGreenMat:(CGRect)eye
{
    cv::Mat rgbMat = [self CVMat3];
    
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    cv::Mat debugMat = cv::Mat();
    eyeROIMat.copyTo(debugMat);
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);

    cv::split(eyeROIMat, channels);

    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    return [[UIImage alloc] initWithCVMat:green.clone()];
}


- (UIImage*)CVGetBlueMat:(CGRect)eye
{
    //cv::Mat rgbaMat = [self CVMat];
    cv::Mat rgbMat = [self CVMat3];
    
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    cv::Mat debugMat = cv::Mat();
    eyeROIMat.copyTo(debugMat);
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();

    //cv::Mat channels = cv::Mat();
    cv::split(eyeROIMat, channels);
    //cv::split(rgbMat, channels);
    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    return [[UIImage alloc] initWithCVMat:blue.clone()];
}
*/

- (UIImage*)CVSubtractMat:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();

    cv::split(eyeROIMat, channels);

    cv::Mat red = channels[0];
    cv::Mat green = channels[1];



    cv::Mat blue = channels[2];
    
    

    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    return [[UIImage alloc] initWithCVMat:red.clone()];
}

- (UIImage*)CVEqualizeMat:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();

    cv::split(eyeROIMat, channels);

    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    cv::equalizeHist(red, red);
    
    return [[UIImage alloc] initWithCVMat:red.clone()];
}


- (UIImage*)CVGaussianMat:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();

    cv::split(eyeROIMat, channels);

    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    return [[UIImage alloc] initWithCVMat:red.clone()];
}


- (UIImage*)CVThresholdMat:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh withRGDifference:(UTF8Char)RGDifference
{
    cv::Mat rgbMat = [self CVMat3];
    
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>();

    cv::split(eyeROIMat, channels);

    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    if (RGDifference > 0) {
        cv::Mat difference = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(RGDifference));
        cv::subtract(redMinusGreen, difference, redMinusGreen);
    }
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(red, red, thresh, 255, cv::THRESH_BINARY);
    
    return [[UIImage alloc] initWithCVMat:red.clone()];
}

- (UIImage*)CVDrawContours:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);

    cv::split(eyeROIMat, channels);

    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(red, red, thresh, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(red, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    cv::drawContours(eyeROIMat, contours, 0, cv::Scalar(0,255,255));
    while (itc!=contours.end()) {
        cv::Rect rect = cv::boundingRect(*itc);
        cv::rectangle(eyeROIMat, rect, cv::Scalar(0,255,255), 0);
        ++itc;
    }
    cv::Mat rgbaEyeROIMat;
    cv::cvtColor(eyeROIMat , rgbaEyeROIMat, CV_RGB2RGBA);
    return [[UIImage alloc] initWithCVMat:rgbaEyeROIMat.clone()];
    //return [[UIImage alloc] initWithCVMat:debugMat.clone()];
}


- (UIImage*)CVDrawLargestContour:(CGRect)eye withRatio:(float)ratio withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);

    cv::split(eyeROIMat, channels);
    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    /*
    cv::Mat tempRed = red.clone();
    for(int y = 0; y< eye.size.height; y++) {
        for(int x=0; x< eye.size.width; x++) {
            if (red.at<UTF8Char>(y, x) != 0 && (green.at<UTF8Char>(y, x) > greenThresh || blue.at<UTF8Char>(y, x) > greenThresh)){
                NSLog(@"red.at<UTF8Char>(y, x): %d", red.at<UTF8Char>(y, x));
                tempRed.at<UTF8Char>(y, x) = 0;
            }
        }
    }
    */
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(red, red, thresh, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(red, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < ratio * eye.size.width * eye.size.height) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    
    if (!largestContour.empty()){
        std::vector<std::vector<cv::Point> > arrayOfLargestContour(1);
        arrayOfLargestContour[0] = largestContour;
        
        std::vector<cv::Point2f>  contourF;
        cv::Mat(largestContour).copyTo(contourF);
        cv::Mat(largestContour).convertTo(contourF, cv::Mat(contourF).type());
        CvRect boundingRect = cv::boundingRect(largestContour);
        
        cv::drawContours(eyeROIMat, arrayOfLargestContour, 0, cv::Scalar(0,255,255));
        cv::rectangle(eyeROIMat, boundingRect, cv::Scalar(0,255,255), 0);
    }
    cv::Mat rgbaEyeROIMat;
    cv::cvtColor(eyeROIMat , rgbaEyeROIMat, CV_RGB2RGBA);
    return [[UIImage alloc] initWithCVMat:rgbaEyeROIMat.clone()];
    //return [[UIImage alloc] initWithCVMat:eyeROIMat.clone()];
}


- (UIImage*)CVDrawMinCircleLargestContour:(CGRect)eye withRatio:(float)ratio withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);
    
    cv::split(eyeROIMat, channels);
    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(red, red, thresh, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(red, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < ratio * eye.size.width * eye.size.height) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    
    if (!largestContour.empty()){
        cv::Point2f center = cv::Point2f(0,0);
        float radius = 0;
        cv::minEnclosingCircle(largestContour, center, radius);
        cv::circle(eyeROIMat, center, radius, cv::Scalar(0,255,255));
        
        std::vector<std::vector<cv::Point> > arrayOfLargestContour(1);
        arrayOfLargestContour[0] = largestContour;
        cv::drawContours(eyeROIMat, arrayOfLargestContour, 0, cv::Scalar(0,255,255));
    }
    cv::Mat rgbaEyeROIMat;
    cv::cvtColor(eyeROIMat , rgbaEyeROIMat, CV_RGB2RGBA);
    return [[UIImage alloc] initWithCVMat:rgbaEyeROIMat.clone()];
}



- (UInt32*)CVGetPupil:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);
    
    cv::split(eyeROIMat, channels);
    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);
    
    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(red, red, thresh, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(red, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < .25 * eye.size.width * eye.size.height) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    
    static UInt32 results [4] = {0,0,0,0};
    results[0] = 0;
    results[1] = 0;
    results[2] = 0;
    results[3] = 0;
    
    if (!largestContour.empty()){
        std::vector<cv::Point2f>  contourF;
        cv::Mat(largestContour).copyTo(contourF);
        cv::Mat(largestContour).convertTo(contourF, cv::Mat(contourF).type());

        CvRect boundingRect = cv::boundingRect(largestContour);
        cv::Point p = cv::Point();
        
        for(int y = boundingRect.y; y < boundingRect.y + boundingRect.height; y++) {
            p.y = y;
            for(int x = boundingRect.x; x < boundingRect.x + boundingRect.width; x++) {
                p.x = x;
                if(cv::pointPolygonTest(contourF, p, false) >= 0) {
                    cv::Vec3b pixel = eyeROIMat.at<cv::Vec3b>(y, x);
                    NSLog(@"(%d,%d) r=%d, g=%d, b=%d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                    results[0] += pixel.val[0];
                    results[1] += pixel.val[1];
                    results[2] += pixel.val[2];
                    results[3] += 1;
                }
            }
        }
    }
    return results;

}

- (UInt32*)CVGetPixelSumFromMinCircle:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    //cv::Mat rgbaMat = [self CVMat];
    cv::Mat rgbMat = [self CVMat3];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);
    
    cv::split(eyeROIMat, channels);
    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(red, red, thresh, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(red, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < .25 * eye.size.width * eye.size.height) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    
    static UInt32 results [4] = {0,0,0,0};
    results[0] = 0;
    results[1] = 0;
    results[2] = 0;
    results[3] = 0;
    
    if (!largestContour.empty()){
        cv::Point2f center = cv::Point2f(0,0);
        float radius = 0;
        cv::minEnclosingCircle(largestContour, center, radius);
        CvRect boundingRect = cv::boundingRect(largestContour);

        //NSLog(@"eye: (%f, %f, %f, %f)\n", eye.origin.x, eye.origin.y, eye.size.width, eye.size.height);
        //NSLog(@"boundingRect: (%d, %d, %d, %d)\n", boundingRect.x, boundingRect.y, boundingRect.width, boundingRect.height);
        //NSLog(@"circle: (%f, %f, %f)", center.x, center.y, radius);
        for(int y = boundingRect.y; y < boundingRect.y + boundingRect.height; y++) {
            for(int x = boundingRect.x; x < boundingRect.x + boundingRect.width; x++) {
                if (isPointInCircle(center.x, center.y, radius, x, y)) {
                    cv::Vec3b pixel = eyeROIMat.at<cv::Vec3b>(y, x);
                    //NSLog(@"pixel(%d, %d) = (%d, %d, %d)", x, y, pixel.val[0], pixel.val[1], pixel.val[2]);
                    results[0] += pixel.val[0];
                    results[1] += pixel.val[1];
                    results[2] += pixel.val[2];
                    results[3] += 1;
                }
            }
        }
    }
    return results;
}


- (UInt32*)CVGetPixelSumFromDifference:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);
    
    cv::split(eyeROIMat, channels);
    cv::Mat red = channels[0];
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);

    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(red, red, thresh, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(red, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < .25 * eye.size.width * eye.size.height) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    
    static UInt32 results [4] = {0,0,0,0};
    results[0] = 0;
    results[1] = 0;
    results[2] = 0;
    results[3] = 0;
    
    if (!largestContour.empty()){
        cv::Point2f center = cv::Point2f(0,0);
        float radius = 0;
        cv::minEnclosingCircle(largestContour, center, radius);
        CvRect boundingRect = cv::boundingRect(largestContour);
        cv::Point p = cv::Point();
        std::vector<cv::Point2f>  contourF;
        cv::Mat(largestContour).copyTo(contourF);
        cv::Mat(largestContour).convertTo(contourF, cv::Mat(contourF).type());
        for(int y = boundingRect.y; y < boundingRect.y + boundingRect.height; y++) {
            p.y = y;
            for(int x = boundingRect.x; x < boundingRect.x + boundingRect.width; x++) {
                p.x = x;
                
                if ((isPointInCircle(center.x, center.y, radius, x, y)) && (cv::pointPolygonTest(contourF, p, false) < 0)){
                    cv::Vec3b pixel = eyeROIMat.at<cv::Vec3b>(y, x);
                    results[0] += pixel.val[0];
                    results[1] += pixel.val[1];
                    results[2] += pixel.val[2];
                    results[3] += 1;
                }
            }
        }
    }
    return results;
}


- (UInt32*)CVGetPixelSum:(CGRect)eye withRatio:(float)ratio withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    cv::Mat rgbMat = [self CVMat3];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat debugMat = cv::Mat();
    //eyeROIMat.copyTo(debugMat);
    
    std::vector<cv::Mat>  channels = std::vector<cv::Mat>(3);
    
    cv::split(eyeROIMat, channels);
    cv::Mat red = channels[0];
    cv::Mat redMinusGreen = red.clone();
    cv::Mat redMinusBlue = red.clone();
    cv::Mat green = channels[1];
    cv::Mat blue = channels[2];
    
    cv::subtract(red, green, redMinusGreen);
    cv::subtract(red, blue, redMinusBlue);
    cv::min(redMinusGreen, redMinusBlue, red);
    
    cv::Mat operand = cv::Mat(eye.size.width, eye.size.height, green.type(), cv::Scalar(255));
    
    green -= cv::Scalar(greenThresh);
    cv::multiply(green, operand, green);
    cv::bitwise_not(green, green);
    cv::bitwise_and(red, green, red);
    
    blue -= cv::Scalar(blueThresh);
    cv::multiply(blue, operand, blue);
    cv::bitwise_not(blue, blue);
    cv::bitwise_and(red, blue, red);
    
    cv::equalizeHist(red, red);
    cv::GaussianBlur(red, red, cv::Size(3.0, 3.0), 0);
    
    cv::threshold(red, red, thresh, 255, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(red, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    std::vector<std::vector<cv::Point> >::iterator itc = contours.begin();
    std::vector<cv::Point> largestContour;
    
    while (itc!=contours.end()) {
        double area = cv::contourArea(*itc);
        cv::Rect rect = cv::boundingRect(*itc);
        
        if (std::abs(1 - ((double)rect.width / (double)rect.height)) < 0.4
            && area < ratio * eye.size.width * eye.size.height) {
            if (largestContour.empty()) {
                largestContour = *itc;
            } else if (area>cv::contourArea(largestContour)) {
                largestContour = *itc;
            }
        }
        ++itc;
    }
    
    static UInt32 results [8] = {0,0,0,0,0,0,0,0};
    results[0] = 0;
    results[1] = 0;
    results[2] = 0;
    results[3] = 0;
    results[4] = 0;
    results[5] = 0;
    results[6] = 0;
    results[7] = 0;
    
    if (!largestContour.empty()){
        cv::Point2f center = cv::Point2f(0,0);
        float radius = 0;
        cv::minEnclosingCircle(largestContour, center, radius);        
        CvRect boundingRect = cv::boundingRect(largestContour);
        cv::Point p = cv::Point();
        std::vector<cv::Point2f>  contourF;
        cv::Mat(largestContour).copyTo(contourF);
        cv::Mat(largestContour).convertTo(contourF, cv::Mat(contourF).type());
        
        
        NSLog(@"boundingRect: (%d, %d, %d, %d)\n", boundingRect.x, boundingRect.y, boundingRect.width, boundingRect.height);
        
        for(int y = boundingRect.y; y < boundingRect.y + boundingRect.height; y++) {
            p.y = y;
            for(int x = boundingRect.x; x < boundingRect.x + boundingRect.width; x++) {
                p.x = x;
                cv::Vec3b pixel = eyeROIMat.at<cv::Vec3b>(y, x);
                if (isPointInCircle(center.x, center.y, radius, x, y)) {
                    if (cv::pointPolygonTest(contourF, p, false) < 0) {
                        results[4] += pixel.val[0];
                        results[5] += pixel.val[1];
                        results[6] += pixel.val[2];
                        results[7] += 1;
                    } else {
                        results[0] += pixel.val[0];
                        results[1] += pixel.val[1];
                        results[2] += pixel.val[2];
                        results[3] += 1;
                    }
                }
            }
        }
    }
    return results;
}

//test if coordinate (x, y) is within a radius from coordinate (center_x, center_y)
Boolean isPointInCircle(double centerX, double centerY,
                               double radius, double x, double y)
{
    double dx = centerX - x;
    double dy = centerY - y;
    dx *= dx;
    dy *= dy;
    double distanceSquared = dx + dy;
    double radiusSquared = radius * radius;
    return distanceSquared <= radiusSquared;
}

-(UIImage *)CVGrayPupils:(CGRect)eye
{
    cv::Mat rgbMat = [self CVMat];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat src = [self CVMat];
    cv::Mat gray;
    cv::cvtColor(~eyeROIMat , gray , CV_BGRA2GRAY);

    return [[UIImage alloc] initWithCVMat:gray.clone()];
}


-(UIImage *)CVGrayPupilsWithThresh:(double)thresh withMaxValue:(double)maxValue withEyeRect:(CGRect)eye
{
    cv::Mat rgbMat = [self CVMat];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();
    
    //cv::Mat src = [self CVMat];
    cv::Mat gray;
    cv::cvtColor(~eyeROIMat , gray , CV_BGRA2GRAY);
    
    cv::equalizeHist(gray, gray);
    cv::GaussianBlur(gray, gray, cv::Size(9.0, 9.0), 7, 7);
    cv::Mat bilateralResult;
    cv::bilateralFilter(gray, bilateralResult, 9, 75, 75);
    
    cv::threshold(gray, gray, thresh, maxValue, cv::THRESH_BINARY);
    return [[UIImage alloc] initWithCVMat:bilateralResult.clone()];

}

-(UIImage *)CVFindPupils:(double)thresh withMaxValue:(double)maxValue withEyeRect:(CGRect)eye
{
    cv::Mat rgbMat = [self CVMat];
    cv::Mat eyeROIMat = rgbMat(cv::Rect(eye.origin.x, eye.origin.y, eye.size.width, eye.size.height)).clone();

    //cv::Mat src = [self CVMat];
    cv::Mat gray;
    cv::cvtColor(~eyeROIMat , gray , CV_BGRA2GRAY);
    
    cv::equalizeHist(gray, gray);
    cv::GaussianBlur(gray, gray, cv::Size(9.0, 9.0), 7, 7);
    

    cv::threshold(gray, gray, thresh, maxValue, cv::THRESH_BINARY);
    
    //return [[UIImage alloc] initWithCVMat:gray];

    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    
    //cv::findContours(gray.clone(), contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    cv::findContours(gray.clone(), contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    
    /*
    for (int i = 0; i < contours.size(); i++)
    {
        double area = cv::contourArea(contours[i]);
        cv::Rect rect = cv::boundingRect(contours[i]);
        int radius = rect.width/2;
        
        // If contour is big enough and has round shape
        // Then it is the pupil
        NSLog(@"area: %f, rect(%d, %d, %d, %d))", area, rect.x, rect.y, rect.width, rect.height);
    }
    */
    
    // Fill holes in each contour
    cv::drawContours(gray, contours, -1, CV_RGB(0,255,255), -1);
    //return [[UIImage alloc] initWithCVMat:gray.clone()];
    
    for (int i = 0; i < contours.size(); i++)
    {
        double area = cv::contourArea(contours[i]);
        cv::Rect rect = cv::boundingRect(contours[i]);
        int radius = rect.width/2;
        
        // If contour is big enough and has round shape
        // Then it is the pupil
        NSLog(@"area: %f, rect(%d, %d, %d, %d))", area, rect.x, rect.y, rect.width, rect.height);
        if (area >= 30) {
            //cv::rectangle(eyeROIMat, rect, CV_RGB(0,255,255));
            cv::Point2f center = cv::Point2f(0,0);
            float radius = 0;
            cv::minEnclosingCircle(contours[i], center, radius);
            cv::circle(eyeROIMat, center, radius, cv::Scalar(0,255,255));
        }
        
        if (area >= 30 &&
            std::abs(1 - ((double)rect.width / (double)rect.height)) <= 0.2 &&
            std::abs(1 - (area / (CV_PI * std::pow(radius, 2)))) <= 0.2)
        {
            cv::circle(eyeROIMat, cv::Point(rect.x + radius, rect.y + radius), radius, CV_RGB(255,0,0), 2);
        }
    }
    return [[UIImage alloc] initWithCVMat:eyeROIMat.clone()];
}



+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    return [[UIImage alloc] initWithCVMat:cvMat];
}

- (id)initWithCVMat:(const cv::Mat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

        // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );                     
    
        // Getting UIImage from CGImage
    self = [self initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return self;
}



@end
