//
//  SLSelectImageViewController.h
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/4.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLSelectImageViewController : UIViewController

//相册缩略图列表
@property (nonatomic, strong) UICollectionView *collectionView;

//选中的的照片
@property (nonatomic, strong) NSMutableArray *arraySelectedImageAssets;

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectedCount;

@property (nonatomic, copy) void(^seletedArrBlock)(NSMutableArray *arr);

+ (SLSelectImageViewController *)defaultSelectImageVC;

//用于回调上级列表，把已选择的图片传回去
//@property (nonatomic, weak) ZLPhotoBrowser *sender;

//选则完成后回调
//@property (nonatomic, copy) void (^DoneBlock)(NSArray<ZLSelectPhotoModel *> *selPhotoModels, NSArray<UIImage *> *selPhotos);
//取消选择后回调
//@property (nonatomic, copy) void (^CancelBlock)();

@end
