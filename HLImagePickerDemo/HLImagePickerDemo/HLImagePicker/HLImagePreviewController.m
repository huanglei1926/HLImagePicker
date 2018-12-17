//
//  SCImagePreviewController.m
//  SunshineConsult
//
//  Created by cainiu on 2018/12/3.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import "HLImagePreviewController.h"
#import "HLMacroConfig.h"
#import "UIView+HLLayout.h"
#import "HLAlbumModel.h"
#import "HLImageManager.h"
#import "UIImage+HLCommon.h"
#import "HLImagePickerController.h"


@interface HLImagePreviewCollectionViewCell : UICollectionViewCell<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scaleScrollView;

@property (nonatomic, strong) UIView *imageContainerView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) HLAssetModel *assetModel;

@property (nonatomic, copy) void(^singleTapActionBlock)(void);

- (void)resetScaleData;

@end

@implementation HLImagePreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
        [self addTapAction];
    }
    return self;
}

- (void)initSubViews{
    _scaleScrollView = [UIScrollView new];
    _scaleScrollView.bouncesZoom = YES;
    _scaleScrollView.maximumZoomScale = 2.5;
    _scaleScrollView.minimumZoomScale = 1.0;
    _scaleScrollView.multipleTouchEnabled = YES;
    _scaleScrollView.delegate = self;
    _scaleScrollView.showsVerticalScrollIndicator = NO;
    _scaleScrollView.showsHorizontalScrollIndicator = NO;
    _scaleScrollView.scrollsToTop = NO;
    _scaleScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scaleScrollView.delaysContentTouches = NO;
    _scaleScrollView.canCancelContentTouches = YES;
    _scaleScrollView.alwaysBounceVertical = NO;
    if (@available(iOS 11, *)) {
        _scaleScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:_scaleScrollView];
    
    _imageContainerView = [UIView new];
    _imageContainerView.clipsToBounds = YES;
    [_scaleScrollView addSubview:_imageContainerView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    [_imageContainerView addSubview:_imageView];
}


- (void)resetScaleData{
    [_scaleScrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _imageContainerView.hl_origin = CGPointZero;
    _imageContainerView.hl_width = self.scaleScrollView.hl_width;
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.hl_height / self.scaleScrollView.hl_width) {
        _imageContainerView.hl_height = floor(image.size.height / (image.size.width / self.scaleScrollView.hl_width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.scaleScrollView.hl_width;
        if (height < 1 || isnan(height)) height = self.hl_height;
        height = floor(height);
        _imageContainerView.hl_height = height;
        _imageContainerView.hl_centerY = self.hl_height / 2;
    }
    if (_imageContainerView.hl_height > self.hl_height && _imageContainerView.hl_height - self.hl_height <= 1) {
        _imageContainerView.hl_height = self.hl_height;
    }
    CGFloat contentSizeH = MAX(_imageContainerView.hl_height, self.hl_height);
    _scaleScrollView.contentSize = CGSizeMake(self.scaleScrollView.hl_width, contentSizeH);
    [_scaleScrollView scrollRectToVisible:self.bounds animated:NO];
    _scaleScrollView.alwaysBounceVertical = _imageContainerView.hl_height <= self.hl_height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
}


- (void)addTapAction{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    //双击失败时触发单击
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

//单击
- (void)singleTapAction:(UITapGestureRecognizer *)singleTap{
    if (self.singleTapActionBlock) {
        self.singleTapActionBlock();
    }
}
//双击
- (void)doubleTapAction:(UITapGestureRecognizer *)doubleTap{
    if (self.scaleScrollView.zoomScale > 1.0 || self.scaleScrollView.zoomScale < 1.0) {
        [self.scaleScrollView setZoomScale:1.0 animated:YES];
    }else{
        CGPoint touchPoint = [doubleTap locationInView:self.imageView];
        CGFloat newZoomScale = self.scaleScrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        CGRect zoomRect = CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize);
        [self.scaleScrollView zoomToRect:zoomRect animated:YES];
    }
}

- (void)setAssetModel:(HLAssetModel *)assetModel{
    _assetModel = assetModel;
    @HLWeakify(self)
    [[HLImageManager defaultManager] fetchPhotoWithAssetModel:assetModel PhotoWidth:kHLScreenW completion:^(UIImage * _Nonnull photoImage) {
        @HLStrongify(self)
        self.imageView.image = photoImage;
    }];
    [self resetScaleData];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scaleScrollView.frame = CGRectMake(10, 0, self.hl_width - 20, self.hl_height);
    self.imageContainerView.frame = self.scaleScrollView.bounds;
    self.imageView.frame = self.imageContainerView.bounds;
    
    [self resetScaleData];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)refreshImageContainerViewCenter{
    CGFloat offsetX = (_scaleScrollView.hl_width > _scaleScrollView.contentSize.width) ? ((_scaleScrollView.hl_width - _scaleScrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scaleScrollView.hl_height > _scaleScrollView.contentSize.height) ? ((_scaleScrollView.hl_height - _scaleScrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(_scaleScrollView.contentSize.width * 0.5 + offsetX, _scaleScrollView.contentSize.height * 0.5 + offsetY);
}

@end


@interface HLImagePreviewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) BOOL isHiddenStatuBar;

@property (nonatomic, assign) BOOL isHideNavBar;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation HLImagePreviewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self updateSelectButton];
    if (!self.isHiddenStatuBar) {
        self.isHiddenStatuBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.isHiddenStatuBar) {
        self.isHiddenStatuBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)prefersStatusBarHidden{
    return self.isHiddenStatuBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)initSubViews{
    self.view.backgroundColor = [UIColor blackColor];
    [self initCollectionView];
    [self initTopView];
    [self initBottomView];
    
    [self.collectionView reloadData];
    if (self.currentIndex > 0 && self.allAssetModels.count > self.currentIndex) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)initTopView{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kHLScreenW, kHLSafeAreaTopHeight)];
    _topView.backgroundColor = kHLColorHexValueAlpha(0x212121, 0.7);
    [self.view addSubview:_topView];
    
    CGFloat bacButtonW = 30;
    UIButton *navBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBackButton setImage:[UIImage imageNamedWithBundleName:@"nav_back"] forState:UIControlStateNormal];
    navBackButton.frame = CGRectMake(12, (64 - bacButtonW) * 0.5 + kHLSafeAreaTopMargin, bacButtonW, bacButtonW);
    [navBackButton addTarget:self action:@selector(navBackBottonAction) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:navBackButton];
    
    CGFloat selectButtonW = 26;
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectButton.showsTouchWhenHighlighted = NO;
    _selectButton.adjustsImageWhenHighlighted = NO;
    _selectButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _selectButton.layer.cornerRadius = selectButtonW * 0.5;
    _selectButton.layer.masksToBounds = YES;
    [_selectButton setBackgroundImage:[UIImage imageNamedWithBundleName:@"item_noselect"] forState:UIControlStateNormal];
    [_selectButton addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    _selectButton.frame = CGRectMake(_topView.hl_width - 12 - selectButtonW, (kHLSafeAreaTopHeight - kHLSafeAreaTopMargin - selectButtonW) * 0.5, selectButtonW, selectButtonW);
    _selectButton.hl_centerY = navBackButton.hl_centerY;
    [_topView addSubview:_selectButton];
}

- (void)navBackBottonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSelectButton:(UIButton *)button{
    if (self.allAssetModels.count > _currentIndex) {
        HLAssetModel *assetModel = self.allAssetModels[_currentIndex];
        [self selectButtonWithAssetModel:assetModel];
    }
}

//选中/取消选中数据
- (void)selectButtonWithAssetModel:(HLAssetModel *)assetModel{
    if (self.selectModelBlock) {
        self.selectModelBlock(assetModel);
    }
    [self updateSelectButton];
    [self updateSelectCount];
}

- (void)updateSelectButton{
    if (self.allAssetModels.count > _currentIndex) {
        HLAssetModel *assetModel = self.allAssetModels[_currentIndex];
        HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.navigationController;
        if ([imagePickerVc.selectedAssetIds containsObject:assetModel.asset.localIdentifier]) {
            [self.selectButton setBackgroundImage:[UIImage imageNamedWithBundleName:@""] forState:UIControlStateNormal];
            [self.selectButton setBackgroundColor:kHLGreenColor];
            NSInteger currentIndex = [imagePickerVc.selectedAssetIds indexOfObject:assetModel.asset.localIdentifier] + 1;
            [self.selectButton setTitle:[NSString stringWithFormat:@"%zd",currentIndex] forState:UIControlStateNormal];
        }else{
            [self.selectButton setBackgroundImage:[UIImage imageNamedWithBundleName:@"item_noselect"] forState:UIControlStateNormal];
            [self.selectButton setTitle:@"" forState:UIControlStateNormal];
            [self.selectButton setBackgroundColor:[UIColor clearColor]];
        }
    }
}

- (void)updateSelectCount{
    HLImagePickerController *imagePicker = (HLImagePickerController *)self.navigationController;
    if (imagePicker.selectedModels.count) {
        self.doneButton.enabled = YES;
        self.doneButton.backgroundColor = kHLGreenColor;
        [self.doneButton setTitle:[NSString stringWithFormat:@"完成(%zd)",imagePicker.selectedModels.count] forState:UIControlStateNormal];
    }else{
        self.doneButton.enabled = NO;
        self.doneButton.backgroundColor = kHLColorHexValueAlpha(0x1EA114,0.6);
        [self.doneButton setTitle:@"完成" forState:UIControlStateNormal];
    }
}

- (void)updateCurrentViewStatu{
    self.isHideNavBar = !self.isHideNavBar;
    self.topView.hidden = self.isHideNavBar;
    self.bottomView.hidden = self.isHideNavBar;
}

- (void)initBottomView{
    CGFloat bottomH = 49 + kHLSafeAreaBottomHeight;
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kHLScreenH - bottomH, kHLScreenW, bottomH)];
    _bottomView.backgroundColor = kHLColorHexValueAlpha(0x212121, 0.7);
    [self.view addSubview:_bottomView];
    
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
    
    [self updateSelectCount];
}

- (void)doneButtonAction{
    if (self.selectFinishBlock) {
        self.selectFinishBlock();
    }
}

- (void)initCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.hl_width + 20, self.view.hl_height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.hl_width + 20, self.view.hl_height) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.contentOffset = CGPointZero;
    _collectionView.contentSize = CGSizeMake(self.allAssetModels.count * (kHLScreenW + 20), 0);
    if (@available(iOS 11, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[HLImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:@"HLImagePreviewCollectionViewCell"];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allAssetModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLImagePreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLImagePreviewCollectionViewCell" forIndexPath:indexPath];
    cell.assetModel = self.allAssetModels[indexPath.item];
    @HLWeakify(self)
    cell.singleTapActionBlock = ^{
        @HLStrongify(self)
        [self updateCurrentViewStatu];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HLImagePreviewCollectionViewCell class]]) {
        [(HLImagePreviewCollectionViewCell *)cell resetScaleData];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HLImagePreviewCollectionViewCell class]]) {
        [(HLImagePreviewCollectionViewCell *)cell resetScaleData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.hl_width + 20) * 0.5);
    NSInteger currentIndex = offSetWidth / (self.view.hl_width + 20);
    if (currentIndex < self.allAssetModels.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self updateSelectButton];
    }
}


- (void)showAlertMessage:(NSString *)alertMessage{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}


- (void)dealloc{
    NSLog(@"%@---dealloc",NSStringFromClass([self class]));
}

@end
