//
//  HLImagePickerController.h
//  SunshineConsult
//
//  Created by cainiu on 2018/11/14.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLMacroConfig.h"

@class HLAssetModel;
@class HLImagePickerController;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HLSelectFinishBlock)(NSArray *imageArray, NSArray *assetArray, HLImagePickerController *imagePicker);
typedef void(^HLSelectCancelBlock)(void);

@interface HLImagePickerController : UINavigationController

/** 最大张数,默认9张,0为不限 */
@property (nonatomic, assign) NSInteger maxImagesCount;

/** 最小张数,默认1张 */
@property (nonatomic, assign) NSInteger minImagesCount;

/** 是否显示相机,默认YES */
@property (nonatomic, assign) BOOL isShowCamera;

/** 是否允许预览图片,默认YES */
@property (nonatomic, assign) BOOL isAllowPreview;

/** 是否自动Dismiss,默认YES */
@property (nonatomic, assign) BOOL isAutoDismiss;

@property (nonatomic, strong) NSMutableArray<HLAssetModel *> *selectedModels;
@property (nonatomic, strong) NSMutableArray *selectedAssetIds;

/** 选择完成 */
@property (nonatomic, copy) HLSelectFinishBlock selectFinishBlock;

/** 点击取消 */
@property (nonatomic, copy) HLSelectCancelBlock selectCacncelBlock;

/** 是否选中原图按钮 */
@property (nonatomic, assign) BOOL isSelectOriginalButton;

/**
 新增选中的Item
 */
- (void)addSelectAssetModel:(HLAssetModel *)assetModel;

/**
 移除选中的Item
 */
- (void)removeSelectAssetModel:(HLAssetModel *)assetModel;

@end

NS_ASSUME_NONNULL_END
