//
//  SLCollectionViewCell.h
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/4.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;

@end
