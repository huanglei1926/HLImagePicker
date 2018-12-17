//
//  HLImageManager.h
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HLAlbumModel;
@class HLAssetModel;
@class PHAsset;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HLAuthorizationStatus) {
    HLAuthorizationStatusNotDetermined = 0,
    HLAuthorizationStatusRestricted,
    HLAuthorizationStatusDenied,
    HLAuthorizationStatusAuthorized,
};

@interface HLImageManager : NSObject

+ (instancetype)defaultManager;

/**
 压缩图片尺寸
 */
- (UIImage *)scaleImage:(UIImage *)image targetSize:(CGSize)targetSize;

/**
 获取相册权限
 */
- (HLAuthorizationStatus)authorizationStatus;

/**
 请求相册权限
 */
- (void)requestAuthorizationWithCompletion:(void (^)(HLAuthorizationStatus status))completion;

/**
 获取相册列表集合
 */
- (void)fetchAlbumListCompletion:(void (^)(NSArray *albumList))completion;


/**
 获取包含所有相片的相册(第一次加载展示)
 */
- (void)fetchAllAssetAlbumCompletion:(void (^)(HLAlbumModel *albumModel))completion;


///**
// 获取单张图片,如果为iCloud则下载
// */
//- (void)fetchPhotoWithAsset:(PHAsset *)asset PhotoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photoImage))completion;

/**
 获取单张图片,如果为iCloud则下载
 */
- (void)fetchPhotoWithAssetModel:(HLAssetModel *)assetModel PhotoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photoImage))completion;


/**
 获取批量文件大小(返回M,K)
 */
- (void)getAssetFileSizeWithAssetModelArray:(NSArray *)assetModelArray completion:(void (^)(NSString *fileSize))completion;



/**
 保存图片到相册
 */
- (void)savePhotoToAlbumWithImage:(UIImage *)image completion:(void (^)(PHAsset *asset, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
