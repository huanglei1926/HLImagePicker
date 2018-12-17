//
//  HLMacroConfig.h
//  SunshineConsult
//
//  Created by cainiu on 2018/11/21.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#ifndef HLMacroConfig_h
#define HLMacroConfig_h

#define kHLColorHexValueAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define kHLGreenColor kHLColorHexValueAlpha(0x1EA114,1.0)

// 弱引用
//#define kHLWeakSelf __weak typeof(self) weakSelf = self;
#define kHLScreenW [UIScreen mainScreen].bounds.size.width
#define kHLScreenH [UIScreen mainScreen].bounds.size.height
#define kHLIs_iPhoneX (kHLScreenH == 812.f || kHLScreenH == 896 ? YES : NO)
#define kHLSafeAreaBottomHeight   (kHLIs_iPhoneX ? 34.f : 0.f)
#define kHLSafeAreaTopMargin (kHLIs_iPhoneX ? 24 : 0)
#define kHLSafeAreaTopHeight (64 + kHLSafeAreaTopMargin)

//weak,strong相关
#ifndef HLWeakify
#if DEBUG
#if __has_feature(objc_arc)
#define HLWeakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define HLWeakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define HLWeakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define HLWeakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef HLStrongify
#if DEBUG
#if __has_feature(objc_arc)
#define HLStrongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define HLStrongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define HLStrongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define HLStrongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


#endif /* HLMacroConfig_h */
