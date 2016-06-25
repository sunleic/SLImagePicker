//
//  SLMultiSelectImagesVC.h
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/4.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLMultiSelectImagesVC : UIViewController

//相册缩略图列表
@property (nonatomic, strong) UICollectionView *collectionView;

//选中的照片的数组
@property (nonatomic, strong) NSMutableArray *arraySelectedImageAssets;

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectedCount;

//将选中的图片数组回传
@property (nonatomic, copy) void(^seletedArrBlock)(NSMutableArray *arr);

+ (SLMultiSelectImagesVC *)defaultSelectImageVC;

@end
