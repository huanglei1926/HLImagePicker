//
//  HLSelectImageController.h
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLMacroConfig.h"

@class HLAlbumModel;
@class HLAssetModel;
NS_ASSUME_NONNULL_BEGIN

@interface HLAlbumItemListController : UIViewController

/** 最大张数,默认9张,0为不限 */
@property (nonatomic, assign) NSInteger maxImagesCount;

/** 最小张数,默认0张 */
@property (nonatomic, assign) NSInteger minImagesCount;

/** 是否显示相机,默认NO */
@property (nonatomic, assign) BOOL isShowCamera;

/** 是否允许预览图片,默认YES */
@property (nonatomic, assign) BOOL isAllowPreview;

@property (nonatomic, strong) HLAlbumModel *albumModel;

@end

NS_ASSUME_NONNULL_END
