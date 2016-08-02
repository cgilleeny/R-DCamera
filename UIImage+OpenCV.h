//
//  UIImage+OpenCV.h
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

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface UIImage (OpenCV)

    //cv::Mat to UIImage
+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
- (id)initWithCVMat:(const cv::Mat&)cvMat;
- (void)CVLog:(cv::Mat)rgb withHSV:(cv::Mat)hsv withRect:(CGRect)rect;
    //UIImage to cv::Mat
- (cv::Mat)CVMat;
- (cv::Mat)CVMat3;  // no alpha channel
- (cv::Mat)CVMat4:(cv::Mat)src; // add back alpha channel
- (UTF8Char*)CVMatHSV:(int)x withY:(int)y;
- (UIImage *)CVRedHueMat;
- (UTF8Char*)CVRGBPixelToHSV:(int)x atY:(int)y;
-(UIImage *)CVAfterPrcocessID:(int)process withUpperWheelMin:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax withMinSkinRatio:(float)minSkinRatio withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier;
- (UInt32*)CVGetPixelSumFromPupil:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax withMinSkinRatio:(float)minSkinRatio withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier;

- (cv::Mat)CVGrayscaleMat;
- (UIImage *)CVBlurredMat;
//- (UIImage*)CVGetPupil:(CGRect)rect;
- (UInt32*)CVGetPupil:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
- (UInt32*)CVGetPixelSumFromMinCircle:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
- (UInt32*)CVGetPixelSumFromDifference:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
- (UInt32*)CVGetPixelSum:(CGRect)eye withRatio:(float)ratio withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
//- (UIImage*)CVGetDebugMat:(CGRect)eye;
//- (UIImage*)CVGetRedMat:(CGRect)eye;
//- (UIImage*)CVGetGreenMat:(CGRect)eye;
//- (UIImage*)CVGetBlueMat:(CGRect)eye;

//- (UIImage*)CVDrawLargestContour:(CGRect)eye;
- (UIImage*)CVDrawLargestContour:(CGRect)eye withRatio:(float)ratio withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
- (UIImage*)CVDrawMinCircleLargestContour:(CGRect)eye withRatio:(float)ratio withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
- (UIImage*)CVSubtractMat:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
- (UIImage*)CVEqualizeMat:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
- (UIImage*)CVGaussianMat:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
- (UIImage*)CVThresholdMat:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh withRGDifference:(UTF8Char)RGDifference;
- (UIImage*)CVDrawContours:(CGRect)eye withThresh:(double)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;


//- (UIImage *)CVOutlineCirclesMat;
//-(UIImage *)CVOutlineCirclesMat:(int)inverseRatioResolution;
//-(UIImage *)CVOutlineCirclesMat:(int)inverseRatioResolution withMinDistBetweenCenters:(int)minDistBetweenCenters;
//-(UIImage *)CVOutlineCirclesMat:(int)inverseRatioResolution withMinDistBetweenCenters:(int)minDistBetweenCenters
//    withUpperCannyEdgeThreshold:(int)upperCannyEdgeThreshold;
//-(UIImage *)CVOutlineCirclesMat:(int)inverseRatioResolution withMinDistBetweenCenters:(int)minDistBetweenCenters
//    withUpperCannyEdgeThreshold:(int)upperCannyEdgeThreshold
//   withCenterDetectionThreshold:(int)centerDetectionThreshold;
//-(UIImage *)CVOutlineCirclesMat:(int)inverseRatioResolution withMinDistBetweenCenters:(int)minDistBetweenCenters
//    withUpperCannyEdgeThreshold:(int)upperCannyEdgeThreshold
//   withCenterDetectionThreshold:(int)centerDetectionThreshold
//          withMinRadiusToDetect:(int)minRadiusToDetect
//         withMaxRadiusToDetect:(int)maxRadiusToDetect;

-(UIImage *)CVBilateralFilterMat:(int)pixelDiameter
                  withSigmaColor:(int)sigmaColor
                  withSigmaSpace:(int)sigmaSpace;

-(UIImage *)CVOutlineCirclesMat:(int)inverseRatioResolution withMinDistBetweenCenters:(int)minDistBetweenCenters
    withUpperCannyEdgeThreshold:(int)upperCannyEdgeThreshold
   withCenterDetectionThreshold:(int)centerDetectionThreshold
          withMinRadiusToDetect:(int)minRadiusToDetect
          withMaxRadiusToDetect:(int)maxRadiusToDetect
        withGaussianKernelWidth:(int)gaussianKernelWidth
       withGaussianKernelHeight:(int)gaussianKernelHeight
             withGaussianSigmaX:(int)gaussianSigmaX
             withGaussianSigmaY:(int)gaussianSigmaY;

- (UIImage *)CVFindCirclesMat;
-(UIImage *)CVFindPupils:(double)thresh withMaxValue:(double)maxValue withEyeRect:(CGRect)eye;
-(UIImage *)CVGrayPupils:(CGRect)eye;
-(UIImage *)CVGrayPupilsWithThresh:(double)thresh withMaxValue:(double)maxValue withEyeRect:(CGRect)eye;

@end
