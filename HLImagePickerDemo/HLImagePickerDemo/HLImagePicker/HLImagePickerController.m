//
//  HLImagePickerController.m
//  SunshineConsult
//
//  Created by cainiu on 2018/11/14.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import "HLImagePickerController.h"
#import "HLAlbumGroupListController.h"
#import "HLAlbumItemListController.h"
#import "HLImageManager.h"
#import "UIView+HLLayout.h"
#import "HLAlbumModel.h"


@interface HLAuthorizationPlaceholderView : UIView

@end

@implementation HLAuthorizationPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, self.hl_width - 60, 60)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.text = @"请在iPhone的\"设置-隐私-照片\"选项中,\n允许APP访问你的手机相册";
    titleLabel.numberOfLines = 0;
    [self addSubview:titleLabel];
}

@end


@interface HLImagePickerController ()

/** 无权限占位视图 */
@property (nonatomic, strong) HLAuthorizationPlaceholderView *placeHolderView;

@end

@implementation HLImagePickerController

- (NSMutableArray<HLAssetModel *> *)selectedModels{
    if (!_selectedModels) {
        _selectedModels = [NSMutableArray array];
    }
    return _selectedModels;
}

- (NSMutableArray *)selectedAssetIds{
    if (!_selectedAssetIds) {
        _selectedAssetIds = [NSMutableArray array];
    }
    return _selectedAssetIds;
}


- (instancetype)init{
    HLAlbumGroupListController *albumGroupVc = [HLAlbumGroupListController new];
    albumGroupVc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
    @HLWeakify(self)
    albumGroupVc.dismissVcBlock = ^{
        @HLStrongify(self)
        [self cancelButtonClick];
    };
    if (self = [super initWithRootViewController:albumGroupVc]) {
        [self initConfig];
        [self initSubViews];
    }
    return self;
}

- (void)cancelButtonClick{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.selectCacncelBlock) {
            self.selectCacncelBlock();
        }
    }];
}

- (void)initConfig{
    self.maxImagesCount = 5;
    self.minImagesCount = 1;
    self.isShowCamera = YES;
    self.isAllowPreview = YES;
    self.isAutoDismiss = YES;
    self.isSelectOriginalButton= NO;
}

- (void)initSubViews{
    HLAuthorizationStatus status = [[HLImageManager defaultManager] authorizationStatus];
    if (status != HLAuthorizationStatusAuthorized) {
        //显示无权限界面
        _placeHolderView = [[HLAuthorizationPlaceholderView alloc] initWithFrame:CGRectMake(0, kHLSafeAreaTopHeight, kHLScreenW, kHLScreenH - kHLSafeAreaTopHeight - kHLSafeAreaBottomHeight)];
        [self.view addSubview:_placeHolderView];
        if (status == HLAuthorizationStatusNotDetermined) {
            //请求权限
            @HLWeakify(self)
            [[HLImageManager defaultManager] requestAuthorizationWithCompletion:^(HLAuthorizationStatus status) {
                @HLStrongify(self)
                if (status == HLAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //隐藏无权限界面,弹出图片选择界面,开始加载图片
                        if (self.placeHolderView) {
                            [self.placeHolderView removeFromSuperview];
                            self.placeHolderView = nil;
                        }
                        [self showSelectImageVc];
                    });
                }
            }];
        }
    }else{
        //弹出图片选择界面,开始加载图片
        [self showSelectImageVc];
    }
}

- (void)showSelectImageVc{
    @HLWeakify(self)
    [[HLImageManager defaultManager] fetchAllAssetAlbumCompletion:^(HLAlbumModel * _Nonnull albumModel) {
        @HLStrongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            HLAlbumItemListController *selectImageVc = [HLAlbumItemListController new];
            selectImageVc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
            selectImageVc.albumModel = albumModel;
            [self pushViewController:selectImageVc animated:NO];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

/**
 新增选中的Item
 */
- (void)addSelectAssetModel:(HLAssetModel *)assetModel{
    if (![self.selectedAssetIds containsObject:assetModel.asset.localIdentifier]) {
        [self.selectedAssetIds addObject:assetModel.asset.localIdentifier];
        [self.selectedModels addObject:assetModel];
    }
}

/**
 移除选中的Item
 */
- (void)removeSelectAssetModel:(HLAssetModel *)assetModel{
    if ([self.selectedAssetIds containsObject:assetModel.asset.localIdentifier]) {
        NSInteger index = [self.selectedAssetIds indexOfObject:assetModel.asset.localIdentifier];
        [self.selectedAssetIds removeObject:assetModel.asset.localIdentifier];
        if (self.selectedModels.count > index) {
            [self.selectedModels removeObjectAtIndex:index];
        }
    }
}


@end
