//
//  UIView+HLLayout.m
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import "UIView+HLLayout.h"

@implementation UIView (HLLayout)

- (CGFloat)hl_left{
    return self.frame.origin.x;
}

- (void)setHl_left:(CGFloat)hl_left{
    CGRect frame = self.frame;
    frame.origin.x = hl_left;
    self.frame = frame;
}

- (CGFloat)hl_top{
    return self.frame.origin.y;
}

- (void)setHl_top:(CGFloat)hl_top{
    CGRect frame = self.frame;
    frame.origin.y = hl_top;
    self.frame = frame;
}

- (CGFloat)hl_right{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setHl_right:(CGFloat)hl_right{
    CGRect frame = self.frame;
    frame.origin.x = hl_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)hl_bottom{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setHl_bottom:(CGFloat)hl_bottom{
    CGRect frame = self.frame;
    frame.origin.y = hl_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)hl_width{
    return self.frame.size.width;
}

- (void)setHl_width:(CGFloat)hl_width{
    CGRect frame = self.frame;
    frame.size.width = hl_width;
    self.frame = frame;
}

- (CGFloat)hl_height{
    return self.frame.size.height;
}

- (void)setHl_height:(CGFloat)hl_height{
    CGRect frame = self.frame;
    frame.size.height = hl_height;
    self.frame = frame;
}

- (CGFloat)hl_centerX{
    return self.center.x;
}

- (void)setHl_centerX:(CGFloat)hl_centerX{
    self.center = CGPointMake(hl_centerX, self.center.y);
}

- (CGFloat)hl_centerY{
    return self.center.y;
}

- (void)setHl_centerY:(CGFloat)hl_centerY{
    self.center = CGPointMake(self.center.x, hl_centerY);
}


- (CGPoint)hl_origin{
    return self.frame.origin;
}

- (void)setHl_origin:(CGPoint)hl_origin{
    CGRect frame = self.frame;
    frame.origin = hl_origin;
    self.frame = frame;
}

- (CGSize)hl_size{
    return self.frame.size;
}

- (void)setHl_size:(CGSize)hl_size{
    CGRect frame = self.frame;
    frame.size = hl_size;
    self.frame = frame;
}

@end
