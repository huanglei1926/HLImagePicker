//
//  SCImagePreviewController.h
//  SunshineConsult
//
//  Created by cainiu on 2018/12/3.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLAssetModel;

NS_ASSUME_NONNULL_BEGIN

@interface HLImagePreviewController : UIViewController

@property (nonatomic, copy) NSArray *allAssetModels;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) void(^selectModelBlock)(HLAssetModel *assetModel);

@property (nonatomic, copy) void(^selectFinishBlock)(void);

@end

NS_ASSUME_NONNULL_END
