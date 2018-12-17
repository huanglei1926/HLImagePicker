# HLImagePicker
## 一个图片选择框架
借鉴了TZImagePickerController的部分思路

### 1.Demo设置示例
<img src="https://github.com/huanglei1926/HLImagePicker/blob/master/images/HLImagePickerDemo-1.png" width="375" height="812" alt="Demo设置示例"/>

### 2.相册列表
<img src="https://github.com/huanglei1926/HLImagePicker/blob/master/images/HLImagePickerDemo-2.png" width="375" height="812" alt="相册列表"/>

### 3.照片选择
<img src="https://github.com/huanglei1926/HLImagePicker/blob/master/images/HLImagePickerDemo-3.png" width="375" height="812" alt="照片选择"/>

### 4.预览照片
<img src="https://github.com/huanglei1926/HLImagePicker/blob/master/images/HLImagePickerDemo-4.png" width="375" height="812" alt="预览照片"/>

## 使用
### Import
```Objective-C
#import "HLImagePickerController.h"
```
### 调用图片选择器
```Objective-C
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
```
