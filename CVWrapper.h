//
//  CVWrapper.h
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CVWrapper : NSObject


- (UTF8Char*) HSV:(UIImage*)image withX:(int)x withY:(int)y;
+ (UIImage*) getRedHueImage:(UIImage*)image;
+ (UTF8Char*)rgbPixelToHSV:(UIImage*)image atX:(int)x atY:(int)y;

+ (UIImage*) processImage:(UIImage*)image withProcessID:(int)processId withUpperWheelMin:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax  withMinSkinRatio:(float)minSkinRatio  withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier;
+ (UInt32*) getRGBSumFromPupil:(UIImage*)image withUpperWheelMin:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax withMinSkinRatio:(float)minSkinRatio  withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier;


+ (UIImage*) bilateralFilter:(UIImage*)image withIPixelDiameter:(int32_t)pixelDiameter
              withSigmaColor:(int32_t)sigmaColor
              withSigmaSpace:(int32_t)sigmaSpace;

+ (UIImage*) findCircleObjects:(UIImage*)image;
+ (UIImage*) findPupils:(UIImage*)image withThresh:(int64_t)thresh  withMaxValue:(int64_t)maxValue withEyeRect:(CGRect)eye;
+ (UIImage*) getDrawGray:(UIImage*)image withEyeRect:(CGRect)eye;
+ (UIImage*) getDrawGrayWithThresh:(UIImage*)image withThresh:(int64_t)thresh  withMaxValue:(int64_t)maxValue withEyeRect:(CGRect)eye;
+ (UInt32*) getPupilRGBSum:(UIImage*)image withThresh:(int64_t)thresh withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
+ (UInt32*) getMinCircleRGBSum:(UIImage*)image withThresh:(int64_t)thresh withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
+ (UInt32*) getDifferenceRGBSum:(UIImage*)image withThresh:(int64_t)thresh  withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
+ (UInt32*) getRGBSum:(UIImage*)image withEyeRect:(CGRect)eye withRatio:(float)ratio withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
//+ (UIImage*) getDebugMat:(UIImage*)image withEyeRect:(CGRect)eye;
//+ (UIImage*) getRedMat:(UIImage*)image withEyeRect:(CGRect)eye;
//+ (UIImage*) getGreenMat:(UIImage*)image withEyeRect:(CGRect)eye;
//+ (UIImage*) getBlueMat:(UIImage*)image withEyeRect:(CGRect)eye;
+ (UIImage*) getThresholdMat:(UIImage*)image withEyeRect:(CGRect)eye withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh withRGDifference:(UTF8Char)RGDifference;
+ (UIImage*) getGaussianMat:(UIImage*)image withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
+ (UIImage*) getSubtractMat:(UIImage*)image withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
+ (UIImage*) getEqualizeMat:(UIImage*)image withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
+ (UIImage*) getDrawContoursMat:(UIImage*)image withEyeRect:(CGRect)eye withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;

+ (UIImage*) getDrawLargestContour:(UIImage*)image withEyeRect:(CGRect)eye withRatio:(float)ratio withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;
+ (UIImage*) getDrawMinCircleLargestContour:(UIImage*)image withEyeRect:(CGRect)eye withRatio:(float)ratio withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh;

//+ (UIImage*) outlineCircleObjects:(UIImage*)image withInverseRatioOfResolution:(int)inverseRatioOfResolution;
//+ (UIImage*) outlineCircleObjects:(UIImage*)image withInverseRatioOfResolution:(int32_t)inverseRatioOfResolution;
//+ (UIImage*) outlineCircleObjects:(UIImage*)image withInverseRatioOfResolution:(int32_t)inverseRatioOfResolution withMinDistBetweenCenters:(int32_t)minDistBetweenCenters;
//+ (UIImage*) outlineCircleObjects:(UIImage*)image withInverseRatioOfResolution:(int32_t)inverseRatioOfResolution withMinDistBetweenCenters:(int32_t)minDistBetweenCenters
//      withUpperCannyEdgeThreshold:(int32_t)upperCannyEdgeThreshold;
//+ (UIImage*) outlineCircleObjects:(UIImage*)image withInverseRatioOfResolution:(int32_t)inverseRatioOfResolution withMinDistBetweenCenters:(int32_t)minDistBetweenCenters
//      withUpperCannyEdgeThreshold:(int32_t)upperCannyEdgeThreshold
//     withCenterDetectionThreshold:(int32_t)centerDetectionThreshold;
//+ (UIImage*) outlineCircleObjects:(UIImage*)image withInverseRatioOfResolution:(int32_t)inverseRatioOfResolution
//        withMinDistBetweenCenters:(int32_t)minDistBetweenCenters
//      withUpperCannyEdgeThreshold:(int32_t)upperCannyEdgeThreshold
//     withCenterDetectionThreshold:(int32_t)centerDetectionThreshold
//            withMinRadiusToDetect:(int32_t)minRadiusToDetect
//            withMaxRadiusToDetect:(int32_t)maxRadiusToDetect;

+ (UIImage*) outlineCircleObjects:(UIImage*)image withInverseRatioOfResolution:(int32_t)inverseRatioOfResolution
        withMinDistBetweenCenters:(int32_t)minDistBetweenCenters
      withUpperCannyEdgeThreshold:(int32_t)upperCannyEdgeThreshold
     withCenterDetectionThreshold:(int32_t)centerDetectionThreshold
            withMinRadiusToDetect:(int32_t)minRadiusToDetect
            withMaxRadiusToDetect:(int32_t)maxRadiusToDetect
          withGaussianKernelWidth:(int32_t)gaussianKernelWidth
         withGaussianKernelHeight:(int32_t)gaussianKernelHeight
               withGaussianSigmaX:(int32_t)gaussianSigmaX
               withGaussianSigmaY:(int32_t)gaussianSigmaY;



+ (UIImage*) blurImage:(UIImage*)image;

@end
