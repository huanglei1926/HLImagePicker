//
//  UIImage+HLCommon.h
//  SunshineConsult
//
//  Created by cainiu on 2018/11/21.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HLCommon)

+ (UIImage *)imageNamedWithBundleName:(NSString *)name;

/** 解决旋转90度问题 */
- (UIImage *)fixOrientation;

/** 解决旋转90度问题 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end

NS_ASSUME_NONNULL_END
