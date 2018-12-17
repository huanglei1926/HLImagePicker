//
//  HLImageManager.m
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import "HLImageManager.h"
#import <Photos/Photos.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHFetchResult.h>
#import "HLAlbumModel.h"
#import "UIImage+HLCommon.h"

@implementation HLImageManager

static HLImageManager *_instance = nil;
+ (instancetype)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HLImageManager alloc] init];
    });
    return _instance;
}

- (UIImage *)scaleImage:(UIImage *)image targetSize:(CGSize)targetSize{
    if (image.size.width > targetSize.width) {
        UIGraphicsBeginImageContext(targetSize);
        [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }else{
        return image;
    }
}

- (HLAuthorizationStatus)authorizationStatus{
    return (HLAuthorizationStatus)[PHPhotoLibrary authorizationStatus];
}

- (void)requestAuthorizationWithCompletion:(void (^)(HLAuthorizationStatus status))completion{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        completion((HLAuthorizationStatus)status);
    }];
}

/**
 获取相册列表集合
 */
- (void)fetchAlbumListCompletion:(void (^)(NSArray *albumList))completion{
    PHFetchResult *resutlt = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    NSMutableArray *albums = [NSMutableArray array];
    for (PHAssetCollection *assetCollection in resutlt) {
        HLAlbumModel *albumModel = [self fetchAssetWithCollection:assetCollection];
        if (albumModel) {
            [albums addObject:albumModel];
        }
    }
    if (completion) {
        completion(albums);
    }
}

- (HLAlbumModel *)fetchAssetWithCollection:(PHAssetCollection *)collection{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    //排除空相册
    if (collection.estimatedAssetCount <= 0) return nil;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    if (fetchResult.count < 1) return nil;
    //隐藏相册
    if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) return nil;
    //最近删除
    if (collection.assetCollectionSubtype == 1000000201) return nil;
    

    NSMutableArray *assetModelArray = [NSMutableArray array];
    for (PHAsset *asset in fetchResult) {
        HLAssetModel *assetModel = [HLAssetModel new];
        assetModel.asset = asset;
        [assetModelArray addObject:assetModel];
    }
    HLAlbumModel *albumModel = [HLAlbumModel new];
    albumModel.allAssetModels = assetModelArray;
    albumModel.albumName = collection.localizedTitle;
    albumModel.result = fetchResult;
    return albumModel;
}

/**
 获取包含所有相片的相册(第一次加载展示)
 */
- (void)fetchAllAssetAlbumCompletion:(void (^)(HLAlbumModel *albumModel))completion{
    PHFetchResult *resutlt = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    HLAlbumModel *allAssetAlbum;
    for (PHAssetCollection *assetCollection in resutlt) {
        if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            allAssetAlbum = [self fetchAssetWithCollection:assetCollection];
            break;
        }
    }
    if (completion) {
        completion(allAssetAlbum);
    }
}


/**
 获取单张图片,如果为iCloud则下载
 */
- (void)fetchPhotoWithAssetModel:(HLAssetModel *)assetModel PhotoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photoImage))completion{
    
    if (completion == nil) {
        return;
    }
    
    __block HLAssetModel *newAssetModel = assetModel;
    PHAsset *asset = newAssetModel.asset;
    if (asset == nil) {
        completion(nil);
        return;
    }
    
    if (photoWidth == 0) {
        photoWidth = asset.pixelWidth;
    }
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = photoWidth * 2.0;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            completion(result);
        }else{
            if ([info objectForKey:PHImageResultIsInCloudKey]) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *dataImage = [UIImage imageWithData:imageData];
                    dataImage = [self scaleImage:dataImage targetSize:imageSize];
                    dataImage = [dataImage fixOrientation];
                    if (photoWidth != 0) {
                        newAssetModel.cacheImage = dataImage;
                    }
                    newAssetModel.dataLength = imageData.length;
                    completion(dataImage);
                }];
            }else{
                completion(nil);
            }
        }
    }];
}


/**
 获取批量文件大小(返回M,K)
 */
- (void)getAssetFileSizeWithAssetModelArray:(NSArray *)assetModelArray completion:(void (^)(NSString *fileSize))completion{
    if (completion == nil) {
        return;
    }
    if (assetModelArray == nil || assetModelArray.count == 0) {
        completion(@"0K");
        return;
    }
    
    __block NSInteger dataLength = 0;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (HLAssetModel *tempModel in assetModelArray) {
        if (tempModel.dataLength > 0) {
            dataLength += tempModel.dataLength;
        }else{
            dispatch_group_enter(group);
            __block HLAssetModel *assetModel = tempModel;
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:assetModel.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                assetModel.dataLength = imageData.length;
                dataLength += imageData.length;
                dispatch_group_leave(group);
            }];
        }
    }
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *fileSizeString = [self getFileSizeStringWithDataLength:dataLength];
            completion(fileSizeString);
        });
    });
}

- (NSString *)getFileSizeStringWithDataLength:(NSInteger)dataLength {
    NSString *fileSizeStr;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        fileSizeStr = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        fileSizeStr = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        fileSizeStr = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return fileSizeStr;
}


/**
 保存图片到相册
 */
- (void)savePhotoToAlbumWithImage:(UIImage *)image completion:(void (^)(PHAsset *asset, NSError *error))completion{
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                completion(asset, nil);
            } else if (error) {
                if (completion) {
                    completion(nil, error);
                }
            }
        });
    }];
}




@end
