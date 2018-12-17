//
//  HLAlbumModel.h
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

//@class PHAsset;
//@class PHFetchResult;

@interface HLAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;

/** 文件大小 */
@property (nonatomic, assign) NSInteger dataLength;

/** 缓存图片 */
@property (nonatomic, strong) UIImage *cacheImage;

///** 缓存图片 */
//@property (nonatomic, strong) UIImage *thumbnailImage;

@end


@interface HLAlbumModel : NSObject

/** 相册名 */
@property (nonatomic, copy) NSString *albumName;

/** 所有图片 */
@property (nonatomic, copy) NSArray *allAssetModels;

/** 所有选中图片 */
@property (nonatomic, copy) NSArray *allSelectAssetModels;

/** 选中图片 */
@property (nonatomic, copy) NSArray *selectAssetModels;

/** list选中数量 */
@property (nonatomic, assign) NSUInteger selectCount;

@property (nonatomic, strong) PHFetchResult *result;

@end

NS_ASSUME_NONNULL_END
