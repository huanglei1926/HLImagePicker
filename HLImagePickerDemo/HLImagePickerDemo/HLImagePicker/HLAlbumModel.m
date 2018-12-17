//
//  HLAlbumModel.m
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import "HLAlbumModel.h"

@implementation HLAssetModel

@end


@implementation HLAlbumModel

- (instancetype)init{
    if (self = [super init]) {
        _allAssetModels = @[];
        _selectAssetModels = @[];
        _allSelectAssetModels = @[];
        _selectCount = 0;
    }
    return self;
}

- (NSString *)albumName{
    if (!_albumName) {
        _albumName = @"";
    }
    return _albumName;
}

- (void)setAllSelectAssetModels:(NSArray *)allSelectAssetModels{
    _allSelectAssetModels = allSelectAssetModels;
    if (_allAssetModels) {
        [self updateSelectCount];
    }
}

- (void)updateSelectCount{
    if (_allAssetModels) {
        _selectCount = 0;
        NSMutableArray *selectArray = [NSMutableArray array];
        NSMutableArray *assetArray = [NSMutableArray array];
        for (HLAssetModel *selectModel in _allSelectAssetModels) {
            [assetArray addObject:selectModel.asset];
        }
        for (HLAssetModel *assetModel in _allAssetModels) {
            if ([assetArray containsObject:assetModel.asset]) {
                [selectArray addObject:assetModel];
                _selectCount++;
            }
        }
        _selectAssetModels = selectArray;
    }
}

@end
