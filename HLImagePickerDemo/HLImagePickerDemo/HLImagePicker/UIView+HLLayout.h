//
//  UIView+HLLayout.h
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (HLLayout)

@property (nonatomic) CGFloat hl_left;
@property (nonatomic) CGFloat hl_top;
@property (nonatomic) CGFloat hl_right;
@property (nonatomic) CGFloat hl_bottom;
@property (nonatomic) CGFloat hl_width;
@property (nonatomic) CGFloat hl_height;
@property (nonatomic) CGFloat hl_centerX;
@property (nonatomic) CGFloat hl_centerY;
@property (nonatomic) CGPoint hl_origin;
@property (nonatomic) CGSize  hl_size;

@end

NS_ASSUME_NONNULL_END
