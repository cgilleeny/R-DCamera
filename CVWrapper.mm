//
//  CVWrapper.m
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import "CVWrapper.h"
#import "UIImage+OpenCV.h"
//#import "stitching.h"
//#import "UIImage+Rotate.h"


@implementation CVWrapper

/*
+ (UIImage*) processImageWithOpenCV: (UIImage*) inputImage
{
    NSArray* imageArray = [NSArray arrayWithObject:inputImage];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}

+ (UIImage*) processWithOpenCVImage1:(UIImage*)inputImage1 image2:(UIImage*)inputImage2;
{
    NSArray* imageArray = [NSArray arrayWithObjects:inputImage1,inputImage2,nil];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}
*/
/*
+ (UIImage*) processWithArray:(NSArray*)imageArray
{
    if ([imageArray count]==0){
        NSLog (@"imageArray is empty");
        return 0;
        }
    std::vector<cv::Mat> matImages;

    for (id image in imageArray) {
        if ([image isKindOfClass: [UIImage class]]) {

            UIImage* rotatedImage = [image rotateToImageOrientation];
            cv::Mat matImage = [rotatedImage CVMat3];
            NSLog (@"matImage: %@",image);
            matImages.push_back(matImage);
        }
    }
    NSLog (@"stitching...");
    cv::Mat stitchedMat = stitch (matImages);
    UIImage* result =  [UIImage imageWithCVMat:stitchedMat];
    return result;
}
*/
+ (UIImage*) blurImage:(UIImage*)image
{
    //cv::Mat imageWithCirclesOutlined = [image CVBlurredMat];
    //UIImage* result = [UIImage imageWithCVMat:imageWithCirclesOutlined ];
    //return result;
    return [image CVBlurredMat];
}

+ (UIImage*) getRedHueImage:(UIImage*)image
{
    return [image CVRedHueMat];
}

+ (UTF8Char*)rgbPixelToHSV:(UIImage*)image atX:(int)x atY:(int)y
{
    return [image CVRGBPixelToHSV:x atY:y];
}

+ (UIImage*) processImage:(UIImage*)image withProcessID:(int)processId withUpperWheelMin:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax withMinSkinRatio:(float)minSkinRatio  withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier
{
    return [image CVAfterPrcocessID:processId withUpperWheelMin:upperWheelMin withLowerWheelMax:lowerWheelMax withMinSkinRatio:minSkinRatio withThresh:thresh withRatio:ratio withSkinValMultiplier:skinValMultiplier];
}

+ (UInt32*) getRGBSumFromPupil:(UIImage*)image withUpperWheelMin:(UTF8Char)upperWheelMin withLowerWheelMax:(UTF8Char)lowerWheelMax withMinSkinRatio:(float)minSkinRatio  withThresh:(UInt16)thresh  withRatio:(float)ratio  withSkinValMultiplier:(float)skinValMultiplier
{
    return [image CVGetPixelSumFromPupil:upperWheelMin withLowerWheelMax:lowerWheelMax withMinSkinRatio:minSkinRatio withThresh:thresh withRatio:ratio withSkinValMultiplier:skinValMultiplier];
}

- (UTF8Char*) HSV:(UIImage*)image withX:(int)x withY:(int)y
{
    return [image CVMatHSV:x withY:y];
}


/*
+ (UIImage*) outlinePupil:(UIImage*)image
{
    //cv::Mat imageWithCirclesOutlined = [image CVBlurredMat];
    //UIImage* result = [UIImage imageWithCVMat:imageWithCirclesOutlined ];
    //return result;
    return [image CVOutlineCirclesMat];
}
*/

+ (UIImage*) findCircleObjects:(UIImage*)image
{
    //cv::Mat imageWithCirclesOutlined = [image CVBlurredMat];
    //UIImage* result = [UIImage imageWithCVMat:imageWithCirclesOutlined ];
    //return result;
    return [image CVFindCirclesMat];
}


+ (UIImage*) getThresholdMat:(UIImage*)image withEyeRect:(CGRect)eye withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh withRGDifference:(UTF8Char)RGDifference
{
    return [image CVThresholdMat:eye withThresh:thresh withGreenThresh:greenThresh withBlueThresh:blueThresh withRGDifference:RGDifference];
}

+ (UIImage*) getGaussianMat:(UIImage*)image withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVGaussianMat:eye withGreenThresh:greenThresh withBlueThresh:blueThresh];
}

+ (UIImage*) getEqualizeMat:(UIImage*)image withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVEqualizeMat:eye withGreenThresh:greenThresh withBlueThresh:blueThresh];
}

+ (UIImage*) getDrawContoursMat:(UIImage*)image withEyeRect:(CGRect)eye withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVDrawContours:eye withThresh:thresh withGreenThresh:greenThresh withBlueThresh:blueThresh];
}

+ (UIImage*) getSubtractMat:(UIImage*)image withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVSubtractMat:eye withGreenThresh:greenThresh withBlueThresh:blueThresh];
}

/*
+ (UIImage*) getRedMat:(UIImage*)image withEyeRect:(CGRect)eye
{
    return [image CVGetRedMat:eye];
}

+ (UIImage*) getGreenMat:(UIImage*)image withEyeRect:(CGRect)eye
{
    return [image CVGetGreenMat:eye];
}

+ (UIImage*) getBlueMat:(UIImage*)image withEyeRect:(CGRect)eye
{
    return [image CVGetBlueMat:eye];
}


+ (UIImage*) getDebugMat:(UIImage*)image withEyeRect:(CGRect)eye
{
    return [image CVGetDebugMat:eye];
}
*/

+ (UIImage*) getDrawLargestContour:(UIImage*)image withEyeRect:(CGRect)eye withRatio:(float)ratio withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVDrawLargestContour:eye withRatio:ratio withThresh:thresh withGreenThresh:greenThresh withBlueThresh:blueThresh];
}

+ (UIImage*) getDrawMinCircleLargestContour:(UIImage*)image withEyeRect:(CGRect)eye withRatio:(float)ratio withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVDrawMinCircleLargestContour:eye withRatio:ratio withThresh:thresh withGreenThresh:greenThresh withBlueThresh:blueThresh];
}

+ (UIImage*) getDrawGray:(UIImage*)image withEyeRect:(CGRect)eye
{
    return [image CVGrayPupils:eye];
}

+ (UIImage*) getDrawGrayWithThresh:(UIImage*)image withThresh:(int64_t)thresh  withMaxValue:(int64_t)maxValue withEyeRect:(CGRect)eye
{
    return [image CVGrayPupilsWithThresh:thresh withMaxValue:maxValue withEyeRect:eye];
}

+ (UIImage*) findPupils:(UIImage*)image withThresh:(int64_t)thresh  withMaxValue:(int64_t)maxValue withEyeRect:(CGRect)eye
{
    return [image CVFindPupils:thresh withMaxValue:maxValue withEyeRect:eye];
}

+ (UInt32*) getPupilRGBSum:(UIImage*)image withThresh:(int64_t)thresh withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVGetPupil:eye withThresh:thresh withGreenThresh:greenThresh withBlueThresh:blueThresh];
}


+ (UInt32*) getMinCircleRGBSum:(UIImage*)image withThresh:(int64_t)thresh withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVGetPixelSumFromMinCircle:eye withThresh:thresh withGreenThresh:greenThresh withBlueThresh:blueThresh];
}


+ (UInt32*) getDifferenceRGBSum:(UIImage*)image withThresh:(int64_t)thresh withEyeRect:(CGRect)eye withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVGetPixelSumFromDifference:eye withThresh:thresh withGreenThresh:greenThresh withBlueThresh:blueThresh];
}

+ (UInt32*) getRGBSum:(UIImage*)image withEyeRect:(CGRect)eye withRatio:(float)ratio withThresh:(int64_t)thresh withGreenThresh:(UTF8Char)greenThresh withBlueThresh:(UTF8Char)blueThresh
{
    return [image CVGetPixelSum:eye withRatio:ratio withThresh:thresh withGreenThresh:greenThresh withBlueThresh:blueThresh];
}

+ (UIImage*) outlineCircleObjects:(UIImage*)image withInverseRatioOfResolution:(int32_t)inverseRatioOfResolution
        withMinDistBetweenCenters:(int32_t)minDistBetweenCenters
            withUpperCannyEdgeThreshold:(int32_t)upperCannyEdgeThreshold
            withCenterDetectionThreshold:(int32_t)centerDetectionThreshold
            withMinRadiusToDetect:(int32_t)minRadiusToDetect
            withMaxRadiusToDetect:(int32_t)maxRadiusToDetect
            withGaussianKernelWidth:(int32_t)gaussianKernelWidth
            withGaussianKernelHeight:(int32_t)gaussianKernelHeight
            withGaussianSigmaX:(int32_t)gaussianSigmaX
            withGaussianSigmaY:(int32_t)gaussianSigmaY
{
    //cv::Mat imageWithCirclesOutlined = [image CVBlurredMat];
    //UIImage* result = [UIImage imageWithCVMat:imageWithCirclesOutlined ];
    //return result;
    return [image CVOutlineCirclesMat:inverseRatioOfResolution withMinDistBetweenCenters:minDistBetweenCenters withUpperCannyEdgeThreshold:upperCannyEdgeThreshold
            withCenterDetectionThreshold:centerDetectionThreshold
                withMinRadiusToDetect:minRadiusToDetect
                withMaxRadiusToDetect:maxRadiusToDetect
              withGaussianKernelWidth:gaussianKernelWidth
             withGaussianKernelHeight:gaussianKernelHeight
                   withGaussianSigmaX:gaussianSigmaX
                   withGaussianSigmaY:gaussianSigmaY];
}

+ (UIImage*) bilateralFilter:(UIImage*)image withIPixelDiameter:(int32_t)pixelDiameter
        withSigmaColor:(int32_t)sigmaColor
        withSigmaSpace:(int32_t)sigmaSpace
{
    //cv::Mat imageWithCirclesOutlined = [image CVBlurredMat];
    //UIImage* result = [UIImage imageWithCVMat:imageWithCirclesOutlined ];
    //return result;
    return [image CVBilateralFilterMat:pixelDiameter withSigmaColor:sigmaColor
                        withSigmaSpace:sigmaSpace];
}

@end
