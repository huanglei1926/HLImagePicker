//
//  HLTestSelectImageController.m
//  AgreementHome
//
//  Created by cainiu on 2018/12/7.
//  Copyright © 2018 AgreementHome. All rights reserved.
//

#import "HLTestSelectImageController.h"
#import "HLImagePickerController.h"
#import "HLTestSelectImageScrollView.h"
#import "UIView+HLLayout.h"


static CGFloat deleteButtonW = 25;

@interface HLTestSelectImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) UIImage *currentImage;

@property (nonatomic, copy) void(^clickDeleteButtonBlock)(UIImage *image);

@end

@implementation HLTestSelectImageCell

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
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.showsTouchWhenHighlighted = NO;
    _deleteButton.adjustsImageWhenHighlighted = NO;
    [_deleteButton setImage:[UIImage imageNamed:@"item_delete"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(clickDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
}

- (void)setCurrentImage:(UIImage *)currentImage{
    _currentImage = currentImage;
    self.imageView.image = currentImage;
}

- (void)clickDeleteButton:(UIButton *)button{
    if (button.isHidden == YES) {
        return;
    }
    if (self.clickDeleteButtonBlock) {
        self.clickDeleteButtonBlock(self.currentImage);
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.deleteButton.frame = CGRectMake(self.hl_width - deleteButtonW, 0, deleteButtonW, deleteButtonW);
}

@end

@interface HLTestSelectImageController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) HLTestSelectImageScrollView *configScrollView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation HLTestSelectImageController

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initConfigScrollView];
    [self initCollectionView];
}

- (void)initConfigScrollView{
    _configScrollView = [[NSBundle mainBundle] loadNibNamed:@"HLTestSelectImageScrollView" owner:nil options:nil].lastObject;
    if (@available(iOS 11.0, *)) {
        _configScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _configScrollView.frame = CGRectMake(0, kHLSafeAreaTopMargin + 40, self.view.hl_width, 255);
    [self.view addSubview:_configScrollView];
} 

- (void)initCollectionView{
    CGFloat itemMargin = 5;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = (self.view.hl_width - itemMargin * 5) / 4.0;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumInteritemSpacing = itemMargin;
    flowLayout.minimumLineSpacing = itemMargin;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.configScrollView.hl_bottom + 20, self.view.hl_width, self.view.hl_height - self.configScrollView.hl_bottom - 20) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
    [_collectionView registerClass:[HLTestSelectImageCell class] forCellWithReuseIdentifier:@"HLTestSelectImageCell"];
    [self.view addSubview:_collectionView];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLTestSelectImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLTestSelectImageCell" forIndexPath:indexPath];
    if (indexPath.item == self.dataSource.count) {
        cell.deleteButton.hidden = YES;
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.currentImage = [UIImage imageNamed:@"item_addimage"];
    }else{
        cell.deleteButton.hidden = NO;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.currentImage = self.dataSource[indexPath.item];
        @HLWeakify(self)
        cell.clickDeleteButtonBlock = ^(UIImage *image) {
            @HLStrongify(self)
            if ([self.dataSource containsObject:image]) {
                NSInteger deleteIndex = [self.dataSource indexOfObject:image];
                [self.dataSource removeObjectAtIndex:deleteIndex];
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:deleteIndex inSection:0]]];
            }
        };
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.item == self.dataSource.count) {
        [self showImagePickerVc];
    }
}


- (void)showImagePickerVc{
    HLImagePickerController *imageVc = [[HLImagePickerController alloc] init];
    /** 最大张数,默认9张,0为不限 */
    imageVc.maxImagesCount = [self.configScrollView.maxCountTextField.text integerValue];
    /** 最小张数,默认1张 */
    imageVc.minImagesCount = [self.configScrollView.minCountTextField.text integerValue];
    /** 是否开启拍照,默认开启 */
    imageVc.isShowCamera = self.configScrollView.cameraSwitch.isOn;
    /** 是否允许预览图片,默认YES */
    imageVc.isAllowPreview = self.configScrollView.previewSwitch.isOn;
    /** 是否自动销毁控制器,默认YES */
    imageVc.isAutoDismiss = self.configScrollView.autoDismissSwitch.isOn;
    /** imageArray为UIImage集合,assetArray为PHAsset集合 */
    @HLWeakify(self)
    imageVc.selectFinishBlock = ^(NSArray * _Nonnull imageArray, NSArray * _Nonnull assetArray, HLImagePickerController * _Nonnull imagePicker) {
        @HLStrongify(self)
        [self.dataSource addObjectsFromArray:imageArray];
        [self.collectionView reloadData];
    };
    [self presentViewController:imageVc animated:YES completion:nil];
}


@end
