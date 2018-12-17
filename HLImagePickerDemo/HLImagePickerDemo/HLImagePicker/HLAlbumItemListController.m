//
//  HLSelectImageController.m
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import "HLAlbumItemListController.h"
#import "HLAlbumModel.h"
#import "UIView+HLLayout.h"
#import "UIImage+HLCommon.h"
#import "HLImageManager.h"
#import "HLImagePickerController.h"
#import "HLImagePreviewController.h"
#import <objc/runtime.h>


//扩大点击区域的Button
@interface HLCustomTouchAreaButton : UIButton

//扩大点击区域距离
@property (nonatomic, assign) UIEdgeInsets touchEdgeInset;

@end

@implementation HLCustomTouchAreaButton

static char topNameKey;
static char rightNameKey;
static char bottomNameKey;
static char leftNameKey;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUpTouchEdgeInset];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        [self setUpTouchEdgeInset];
    }
    return self;
}

- (void)setUpTouchEdgeInset
{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:5], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:5], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:5], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:5], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setTouchEdgeInset:(UIEdgeInsets)touchEdgeInset
{
    _touchEdgeInset = touchEdgeInset;
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:touchEdgeInset.top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:touchEdgeInset.right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:touchEdgeInset.bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:touchEdgeInset.left], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)enlargedRect
{
    NSNumber* topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber* rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber* bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber* leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge){
        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
                          self.bounds.origin.y - topEdge.floatValue,
                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
    }else{
        return self.bounds;
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds))
    {
        return [super hitTest:point withEvent:event];
    }
    return (CGRectContainsPoint(rect, point) && !self.isHidden)  ? self : nil;
}

@end


@interface HLAlbumItemCell : UICollectionViewCell

@property (nonatomic, weak) HLAlbumModel *albumModel;
@property (nonatomic, weak) HLAssetModel *assetModel;

@property (nonatomic, strong) HLCustomTouchAreaButton *selectButton;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, weak) HLAlbumItemListController *albumListVc;

- (void)updateModel:(HLAlbumModel *)albumModel index:(NSInteger)index;

@property (nonatomic, copy) void(^clickSelectButtonBlock)(HLAssetModel *assetModel);

@end


static CGFloat selectButtonW = 22;

@implementation HLAlbumItemCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    _imageView = [UIImageView new];
    _imageView.backgroundColor = kHLColorHexValueAlpha(0xdfdfdf, 1.0);
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    _selectButton = [HLCustomTouchAreaButton buttonWithType:UIButtonTypeCustom];
    _selectButton.showsTouchWhenHighlighted = NO;
    _selectButton.adjustsImageWhenHighlighted = NO;
    _selectButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _selectButton.layer.cornerRadius = selectButtonW * 0.5;
    _selectButton.layer.masksToBounds = YES;
    _selectButton.touchEdgeInset = UIEdgeInsetsMake(0, 10, 10, 0);
    [_selectButton setBackgroundImage:[UIImage imageNamedWithBundleName:@"item_noselect"] forState:UIControlStateNormal];
    [_selectButton setBackgroundColor:kHLColorHexValueAlpha(0x666666, 0.4)];
    [_selectButton addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectButton];
}

- (void)updateModel:(HLAlbumModel *)albumModel index:(NSInteger)index{
    _albumModel = albumModel;
    if (albumModel.allAssetModels.count > index) {
        self.selectButton.hidden = NO;
        self.assetModel = albumModel.allAssetModels[index];
    }else{
        self.selectButton.hidden = YES;
    }
}

- (void)setAssetModel:(HLAssetModel *)assetModel{
    _assetModel = assetModel;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (assetModel.cacheImage) {
        self.imageView.image = assetModel.cacheImage;
    }else{
        @HLWeakify(self)
        [[HLImageManager defaultManager] fetchPhotoWithAssetModel:assetModel PhotoWidth:kHLScreenW / 4.0 completion:^(UIImage * _Nonnull photoImage) {
            @HLStrongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = photoImage;
            });
        }];
    }
    [self updateSelectButton];
}

- (void)clickSelectButton:(UIButton *)button{
    if (button.isHidden == YES) {
        return;
    }
    if (self.clickSelectButtonBlock) {
        self.clickSelectButtonBlock(self.assetModel);
    }
}

- (void)updateSelectButton{
    HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.albumListVc.navigationController;
    if ([imagePickerVc.selectedAssetIds containsObject:self.assetModel.asset.localIdentifier]) {
        [self.selectButton setBackgroundImage:[UIImage imageNamedWithBundleName:@""] forState:UIControlStateNormal];
        [self.selectButton setBackgroundColor:kHLGreenColor];
        NSInteger currentIndex = [imagePickerVc.selectedAssetIds indexOfObject:self.assetModel.asset.localIdentifier] + 1;
        [self.selectButton setTitle:[NSString stringWithFormat:@"%zd",currentIndex] forState:UIControlStateNormal];
    }else{
        [self.selectButton setBackgroundImage:[UIImage imageNamedWithBundleName:@"item_noselect"] forState:UIControlStateNormal];
        [self.selectButton setBackgroundColor:kHLColorHexValueAlpha(0x666666, 0.4)];
        [self.selectButton setTitle:@"" forState:UIControlStateNormal];
//        [self.selectButton setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.selectButton.frame = CGRectMake(self.hl_width - selectButtonW, 0, selectButtonW, selectButtonW);
}

@end


@interface HLAlbumItemListController ()<UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *previewButton;

@property (nonatomic, strong) UIButton *originalButton;
@property (nonatomic, strong) UILabel *originalLabel;

@property (nonatomic, strong) UIButton *doneButton;

@end

static CGFloat itemMargin = 5;
static NSString *hlAlbumItemCellID = @"HLAlbumItemCell";
@implementation HLAlbumItemListController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadConfig];
}

- (void)reloadConfig{
    HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.navigationController;
    self.isShowCamera = imagePickerVc.isShowCamera;
    self.isAllowPreview = imagePickerVc.isAllowPreview;
    self.maxImagesCount = imagePickerVc.maxImagesCount;
    self.minImagesCount = imagePickerVc.minImagesCount;
    [self reloadView];
}

- (void)reloadView{
    self.previewButton.hidden = !self.isAllowPreview;
    if (self.isShowCamera) {
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.albumModel.albumName;
    [self initSubViews];
}

- (void)initSubViews{
    [self initBottomView];
    [self initCollectionView];
    [self.collectionView reloadData];
    [self scrollCollectionViewToBottom];
    
    HLImagePickerController *imagePicker = (HLImagePickerController *)self.navigationController;
    self.originalButton.selected = imagePicker.isSelectOriginalButton;
    [self updateSelectCount];
}

- (void)scrollCollectionViewToBottom {
    HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.navigationController;
    if (self.albumModel.allAssetModels.count > 0) {
        NSInteger item = self.albumModel.allAssetModels.count - 1;
        if (imagePickerVc.isShowCamera) {
            item += 1;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        });
    }
}

- (void)initBottomView{
    CGFloat bottomH = 49 + kHLSafeAreaBottomHeight;
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.hl_height - bottomH, self.view.hl_width, bottomH)];
    _bottomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [self.view addSubview:_bottomView];
    
    //预览
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    _previewButton.frame = CGRectMake(10, 0, 50, 49);
    [_previewButton addTarget:self action:@selector(previewButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_previewButton];
    
    //原图
    _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_originalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_originalButton setTitle:@"原图" forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamedWithBundleName:@"original_noselect"] forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamedWithBundleName:@"original_select"] forState:UIControlStateSelected];
    [_originalButton addTarget:self action:@selector(originalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_originalButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    _originalButton.frame = CGRectMake(_bottomView.hl_width * 0.5 - 30, 0, 60, 49);
    [_bottomView addSubview:_originalButton];
    
    _originalLabel = [[UILabel alloc] init];
    _originalLabel.font = _originalButton.titleLabel.font;
    _originalLabel.textColor = [_originalButton titleColorForState:UIControlStateNormal];
    [_bottomView addSubview:_originalLabel];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_doneButton setBackgroundColor:kHLGreenColor];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _doneButton.frame = CGRectMake(_bottomView.hl_width - 67 - 10, 0, 67, 28);
    _doneButton.hl_centerY = 49 * 0.5;
    _doneButton.layer.cornerRadius = 3.0;
    _doneButton.layer.masksToBounds = YES;
    [_doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_doneButton];
}

- (void)updateSelectCount{
    HLImagePickerController *imagePicker = (HLImagePickerController *)self.navigationController;
    if (imagePicker.isSelectOriginalButton) {
        [self updateOriginalButtonTitle];
    }
    if (imagePicker.selectedModels.count) {
        self.previewButton.enabled = YES;
        self.doneButton.enabled = YES;
        self.doneButton.backgroundColor = kHLGreenColor;
        [self.doneButton setTitle:[NSString stringWithFormat:@"完成(%zd)",imagePicker.selectedModels.count] forState:UIControlStateNormal];
    }else{
        self.previewButton.enabled = NO;
        self.doneButton.enabled = NO;
        self.doneButton.backgroundColor = kHLColorHexValueAlpha(0x1EA114,0.6);
        [self.doneButton setTitle:@"完成" forState:UIControlStateNormal];
    }
}

#pragma mark - 预览
- (void)previewButtonAction{
    HLImagePickerController *imagePicker = (HLImagePickerController *)self.navigationController;
    [self lookBigImageWithCurrentIndex:0 assetModelArray:imagePicker.selectedModels];
}


#pragma mark - 原图
- (void)originalButtonAction:(UIButton *)button{
    button.selected = !button.isSelected;
    HLImagePickerController *imagePicker = (HLImagePickerController *)self.navigationController;
    imagePicker.isSelectOriginalButton = button.isSelected;
    [self updateOriginalButtonTitle];
}

- (void)updateOriginalButtonTitle{
    self.originalLabel.hidden = !self.originalButton.isSelected;
    if (self.originalButton.isSelected) {
        [self calculationFileSize];
        
    }else{
        self.originalLabel.text = @"";
    }
}

- (void)calculationFileSize{
    if (self.albumModel.allSelectAssetModels.count > 0) {
        @HLWeakify(self)
        [[HLImageManager defaultManager] getAssetFileSizeWithAssetModelArray:self.albumModel.allSelectAssetModels completion:^(NSString * _Nonnull fileSize) {
            @HLStrongify(self)
            if (fileSize) {
                self.originalLabel.text = fileSize;
                [self.originalLabel sizeToFit];
                self.originalLabel.hl_left = self.originalButton.hl_right;
                self.originalLabel.hl_centerY = self.originalButton.hl_centerY;
            }
        }];
    }else{
        self.originalLabel.text = @"";
    }
}

#pragma mark - 完成
- (void)doneButtonAction{
    HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.navigationController;
    if (imagePickerVc.minImagesCount > imagePickerVc.selectedModels.count || imagePickerVc.selectedModels.count == 0) {
        [self showAlertMessage:[NSString stringWithFormat:@"最少选择%zd张图片",imagePickerVc.minImagesCount]];
        return;
    }
    
    //获取Image
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:imagePickerVc.selectedModels.count];
    NSMutableArray *failArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray arrayWithCapacity:imagePickerVc.selectedModels.count];
    for (int i = 0; i < imagePickerVc.selectedModels.count; i++) {
        [imageArray addObject:@(i)];
        [assetArray addObject:@(i)];
    }
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    CGFloat photoWidth = imagePickerVc.isSelectOriginalButton ? 0 : kHLScreenW;
    for (int i = 0; i < imagePickerVc.selectedModels.count; i++) {
        HLAssetModel *assetModel = imagePickerVc.selectedModels[i];
        [assetArray replaceObjectAtIndex:i withObject:assetModel.asset];
        dispatch_group_enter(group);
        dispatch_async(queue, ^{
            [[HLImageManager defaultManager] fetchPhotoWithAssetModel:assetModel PhotoWidth:photoWidth completion:^(UIImage * _Nonnull photoImage) {
                if (photoImage && [photoImage isKindOfClass:[UIImage class]]) {
                    [imageArray replaceObjectAtIndex:i withObject:photoImage];
                }else{
                    [failArray addObject:[imageArray objectAtIndex:i]];
                }
            }];
            dispatch_group_leave(group);
        });
    }
    
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failArray.count > 0) {
                NSLog(@"获取图片失败,序列-%@",failArray);
                [imageArray removeObjectsInArray:failArray];
            }
            [self selectImageFinishWithImageArray:imageArray assetArray:assetArray];
        });
    });
}

- (void)selectImageFinishWithImageArray:(NSArray *)imageArray assetArray:(NSArray *)assetArray{
    HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.navigationController;
    if (imagePickerVc.isAutoDismiss) {
        [imagePickerVc dismissViewControllerAnimated:YES completion:^{
            if (imagePickerVc.selectFinishBlock) {
                imagePickerVc.selectFinishBlock(imageArray,assetArray,imagePickerVc);
            }
        }];
    }else{
        if (imagePickerVc.selectFinishBlock) {
            imagePickerVc.selectFinishBlock(imageArray,assetArray,imagePickerVc);
        }
    }
}

- (void)initCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = (self.view.hl_width - itemMargin * 5) / 4.0;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumInteritemSpacing = itemMargin;
    flowLayout.minimumLineSpacing = itemMargin;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kHLSafeAreaTopHeight, self.view.hl_width, self.view.hl_height - kHLSafeAreaTopHeight - self.bottomView.hl_height) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
    [_collectionView registerClass:[HLAlbumItemCell class] forCellWithReuseIdentifier:hlAlbumItemCellID];
    [self.view addSubview:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.isShowCamera ? self.albumModel.allAssetModels.count + 1 : self.albumModel.allAssetModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLAlbumItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:hlAlbumItemCellID forIndexPath:indexPath];
    if (indexPath.item == self.albumModel.allAssetModels.count && self.isShowCamera) {
        cell.selectButton.hidden = YES;
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.image = [UIImage imageNamedWithBundleName:@"item_camera"];
    }else{
        cell.albumListVc = self;
        [cell updateModel:self.albumModel index:indexPath.item];
        @HLWeakify(self)
        cell.clickSelectButtonBlock = ^(HLAssetModel *assetModel) {
            @HLStrongify(self)
            [self selectItemImageWithAssetModel:assetModel];
        };
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.albumModel.allAssetModels.count > indexPath.item) {
        [self lookBigImageWithCurrentIndex:indexPath.item assetModelArray:self.albumModel.allAssetModels];
    }else{
        if (self.isShowCamera && self.albumModel.allAssetModels.count == indexPath.item) {
            [self cameraAction];
        }
    }
}

- (void)showAlertMessage:(NSString *)alertMessage{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}


//选中/取消选中数据
- (void)selectItemImageWithAssetModel:(HLAssetModel *)assetModel{
    HLImagePickerController *imagePicker = (HLImagePickerController *)self.navigationController;
    //是否为选中
    BOOL isSelectData = ![imagePicker.selectedAssetIds containsObject:assetModel.asset.localIdentifier];
    if (isSelectData == YES && imagePicker.selectedAssetIds.count >= imagePicker.maxImagesCount && imagePicker.maxImagesCount != 0) {
        [self showAlertMessage:[NSString stringWithFormat:@"最多只能选中%zd张图片",imagePicker.maxImagesCount]];
        return ;
    }
    if (isSelectData) {
        [imagePicker addSelectAssetModel:assetModel];
    }else{
        [imagePicker removeSelectAssetModel:assetModel];
    }
    self.albumModel.allSelectAssetModels = imagePicker.selectedModels;
    
    NSMutableArray *reloadIndexPaths = [NSMutableArray array];
    for (HLAssetModel *selectAssetModel in self.albumModel.allAssetModels) {
        if ([imagePicker.selectedAssetIds containsObject:selectAssetModel.asset.localIdentifier] && ![selectAssetModel.asset.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
            NSInteger index = [self.albumModel.allAssetModels indexOfObject:selectAssetModel];
            [reloadIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
    }
    
    [reloadIndexPaths addObject:[NSIndexPath indexPathForItem:[self.albumModel.allAssetModels indexOfObject:assetModel] inSection:0]];
    [self.collectionView reloadItemsAtIndexPaths:reloadIndexPaths];
    [self updateSelectCount];
}


//相机
- (void)cameraAction{
    [self getCameraAuthority:^(BOOL granted) {
        if (granted) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }];
}

//获取相机权限
- (void)getCameraAuthority:(void(^)(BOOL granted))handler{
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showAlertMessage:@"检测不到相机设备"];
        handler(NO);
        return;
    }
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [self showAlertMessage:@"相机权限受限"];
        handler(NO);
        return;
    }else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(granted);
            });
        }];
    }else{
        handler(YES);
    }
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (photo) {
            [[HLImageManager defaultManager] savePhotoToAlbumWithImage:photo completion:^(PHAsset * _Nonnull asset, NSError * _Nonnull error) {
                if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                }else{
                    [self addPHAsset:asset];
                }
            }];
        }
    }
}

- (void)addPHAsset:(PHAsset *)asset{
    HLAssetModel *assetModel = [[HLAssetModel alloc] init];
    assetModel.asset = asset;
    self.albumModel.allAssetModels = [self.albumModel.allAssetModels arrayByAddingObject:assetModel];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.albumModel.allAssetModels.count - 1 inSection:0]]];
    [self scrollCollectionViewToBottom];
}


#pragma mark - 查看大图(选中或预览)
- (void)lookBigImageWithCurrentIndex:(NSInteger)currentIndex assetModelArray:(NSArray *)assetModelArray{
    HLImagePreviewController *preVc = [HLImagePreviewController new];
    @HLWeakify(self)
    preVc.selectModelBlock = ^(HLAssetModel * _Nonnull assetModel) {
        @HLStrongify(self)
        [self selectItemImageWithAssetModel:assetModel];
    };
    preVc.selectFinishBlock = ^{
        @HLStrongify(self)
        [self doneButtonAction];
    };
    preVc.allAssetModels = assetModelArray;
    preVc.currentIndex = currentIndex;
    [self.navigationController pushViewController:preVc animated:YES];
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
//    self.collectionView.frame = CGRectMake(0, kHLSafeAreaTopHeight, self.view.hl_width, self.view.hl_height - kHLSafeAreaTopHeight - self.bottomView.hl_height);
}

@end
