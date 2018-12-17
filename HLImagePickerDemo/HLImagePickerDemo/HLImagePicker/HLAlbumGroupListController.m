//
//  HLAlbumGroupListController.m
//  SunshineConsult
//
//  Created by cainiu on 2018/11/15.
//  Copyright © 2018 SunshineConsult. All rights reserved.
//

#import "HLAlbumGroupListController.h"
#import "HLImageManager.h"
#import "HLImagePickerController.h"
#import "HLAlbumModel.h"
#import "UIView+HLLayout.h"
#import "HLAlbumItemListController.h"
#import "HLMacroConfig.h"


@interface HLAlbumListCell : UITableViewCell

@property (nonatomic, strong) HLAlbumModel *albumModel;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *desLabel;

@property (nonatomic, strong) UIImageView *countImageView;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation HLAlbumListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    _iconImageView.clipsToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    
    _desLabel = [UILabel new];
    _desLabel.textAlignment = NSTextAlignmentLeft;
    _desLabel.textColor = [UIColor blackColor];
    _desLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.contentView addSubview:_desLabel];
    
    _countLabel = [UILabel new];
    _countLabel.backgroundColor = kHLGreenColor;
    _countLabel.layer.cornerRadius = 12;
    _countLabel.layer.masksToBounds = YES;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:_countLabel];
}


- (void)setAlbumModel:(HLAlbumModel *)albumModel{
    _albumModel = albumModel;
    HLAssetModel *assetModel = albumModel.allAssetModels.lastObject;
    if (assetModel.cacheImage) {
        self.iconImageView.image = assetModel.cacheImage;
    }else{
        @HLWeakify(self)
        [[HLImageManager defaultManager] fetchPhotoWithAssetModel:assetModel PhotoWidth:100 completion:^(UIImage * _Nonnull photoImage) {
            @HLStrongify(self)
            self.iconImageView.image = photoImage;
        }];
    }
    self.desLabel.attributedText = [self getAttriStringWithTitle:albumModel.albumName count:albumModel.allAssetModels.count];
    if (albumModel.selectCount > 0) {
        self.countLabel.hidden = NO;
        self.countLabel.text = [NSString stringWithFormat:@"%zd",albumModel.selectCount];
    }else{
        self.countLabel.hidden = YES;
    }
}

- (NSAttributedString *)getAttriStringWithTitle:(NSString *)title count:(NSInteger)count{
    NSMutableAttributedString *mutableAttr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17], NSForegroundColorAttributeName : [UIColor blackColor]}];
    [mutableAttr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",count] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor darkGrayColor]}]];
    return mutableAttr;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _iconImageView.frame = CGRectMake(0, 0, self.contentView.hl_height, self.contentView.hl_height);
    [_desLabel sizeToFit];
    _desLabel.hl_left = _iconImageView.hl_right + 15;
    _desLabel.hl_centerY = self.contentView.hl_height * 0.5;
    _desLabel.hl_width = self.contentView.hl_width - 40 - _desLabel.hl_left;
    
    _countLabel.frame = CGRectMake(self.contentView.hl_width - 24, 0, 24, 24);
    _countLabel.hl_centerY = self.contentView.hl_height * 0.5;
}

@end


@interface HLAlbumGroupListController ()<UITableViewDelegate, UITableViewDataSource>

/** 相册列表 */
@property (nonatomic, copy) NSArray *albumList;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HLAlbumGroupListController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.albumList == nil || self.albumList.count == 0) {
        [self initDatas];
    }else{
        [self reloadDatas];
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHLSafeAreaTopHeight, self.view.hl_width, self.view.hl_height - kHLSafeAreaTopHeight) style:UITableViewStylePlain];
        _tableView.rowHeight = 70;
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[HLAlbumListCell class] forCellReuseIdentifier:@"HLAlbumListCell"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self initDatas];
}

- (void)initDatas{
    @HLWeakify(self)
    [[HLImageManager defaultManager] fetchAlbumListCompletion:^(NSArray * _Nonnull albumList) {
        @HLStrongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            self.albumList = [NSArray arrayWithArray:albumList];
            [self reloadDatas];
        });
    }];
}

- (void)reloadDatas{
    HLImagePickerController *imagePickerVc = (HLImagePickerController *)self.navigationController;
    for (HLAlbumModel *albumModel in self.albumList) {
        albumModel.allSelectAssetModels = imagePickerVc.selectedModels;
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HLAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLAlbumListCell"];
    cell.albumModel = self.albumList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    HLAlbumItemListController *selectImageVc = [HLAlbumItemListController new];
    selectImageVc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
    selectImageVc.albumModel = self.albumList[indexPath.row];
    [self.navigationController pushViewController:selectImageVc animated:YES];
}

- (void)cancelButtonClick{
    if (self.dismissVcBlock) {
        self.dismissVcBlock();
    }
}


@end
