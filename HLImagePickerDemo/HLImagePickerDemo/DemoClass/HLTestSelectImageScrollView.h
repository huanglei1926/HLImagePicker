//
//  HLTestSelectImageScrollView.h
//  AgreementHome
//
//  Created by cainiu on 2018/12/7.
//  Copyright © 2018 AgreementHome. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLTestSelectImageScrollView : UIScrollView
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *previewSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoDismissSwitch;
@property (weak, nonatomic) IBOutlet UITextField *maxCountTextField;
@property (weak, nonatomic) IBOutlet UITextField *minCountTextField;

@end

NS_ASSUME_NONNULL_END
