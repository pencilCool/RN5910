/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTAnimationUtils.h"

#import <React/RCTLog.h>

static NSUInteger _RCTFindIndexOfNearestValue(CGFloat value, NSArray<NSNumber *> *range)
{
  NSUInteger index;
  NSUInteger rangeCount = range.count;
  for (index = 1; index < rangeCount - 1; index++) {
    NSNumber *inputValue = range[index];
    if (inputValue.doubleValue >= value) {
      break;
    }
  }
  return index - 1;
}

/**
 * Interpolates value by remapping it linearly fromMin->fromMax to toMin->toMax
 */
CGFloat RCTInterpolateValue(CGFloat value,
                            CGFloat inputMin,
                            CGFloat inputMax,
                            CGFloat outputMin,
                            CGFloat outputMax,
                            NSString *extrapolateLeft,
                            NSString *extrapolateRight)
{
  if (value < inputMin) {
    if ([extrapolateLeft isEqualToString:EXTRAPOLATE_TYPE_IDENTITY]) {
      return value;
    } else if ([extrapolateLeft isEqualToString:EXTRAPOLATE_TYPE_CLAMP]) {
      value = inputMin;
    } else if ([extrapolateLeft isEqualToString:EXTRAPOLATE_TYPE_EXTEND]) {
      // noop
    } else {
      RCTLogError(@"Invalid extrapolation type %@ for left extrapolation", extrapolateLeft);
    }
  }

  if (value > inputMax) {
    if ([extrapolateRight isEqualToString:EXTRAPOLATE_TYPE_IDENTITY]) {
      return value;
    } else if ([extrapolateRight isEqualToString:EXTRAPOLATE_TYPE_CLAMP]) {
      value = inputMax;
    } else if ([extrapolateRight isEqualToString:EXTRAPOLATE_TYPE_EXTEND]) {
      // noop
    } else {
      RCTLogError(@"Invalid extrapolation type %@ for right extrapolation", extrapolateRight);
    }
  }

  return outputMin + (value - inputMin) * (outputMax - outputMin) / (inputMax - inputMin);
}

/**
 * Interpolates value by mapping it from the inputRange to the outputRange.
 */
CGFloat RCTInterpolateValueInRange(CGFloat value,
                                   NSArray<NSNumber *> *inputRange,
                                   NSArray<NSNumber *> *outputRange,
                                   NSString *extrapolateLeft,
                                   NSString *extrapolateRight)
{
  NSUInteger rangeIndex = _RCTFindIndexOfNearestValue(value, inputRange);
  CGFloat inputMin = inputRange[rangeIndex].doubleValue;
  CGFloat inputMax = inputRange[rangeIndex + 1].doubleValue;
  CGFloat outputMin = outputRange[rangeIndex].doubleValue;
  CGFloat outputMax = outputRange[rangeIndex + 1].doubleValue;

  return RCTInterpolateValue(value,
                             inputMin,
                             inputMax,
                             outputMin,
                             outputMax,
                             extrapolateLeft,
                             extrapolateRight);
}

CGFloat RCTRadiansToDegrees(CGFloat radians)
{
  return radians * 180.0 / M_PI;
}

CGFloat RCTDegreesToRadians(CGFloat degrees)
{
  return degrees / 180.0 * M_PI;
}

#if TARGET_IPHONE_SIMULATOR
// Based on https://stackoverflow.com/a/13307674
float UIAnimationDragCoefficient(void);
#endif

CGFloat RCTAnimationDragCoefficient(void)
{
#if TARGET_IPHONE_SIMULATOR
  if (NSClassFromString(@"XCTest") != nil) {
    // UIAnimationDragCoefficient is 10.0 in tests for some reason, but
    // we need it to be 1.0. Fixes T34233294
    return 1.0;
  } else {
    return (CGFloat)UIAnimationDragCoefficient();
  }
#else
  return 1.0;
#endif
}
