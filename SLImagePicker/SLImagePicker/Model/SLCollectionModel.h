//
//  SLCollectionModel.h
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/10.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SLCollectionModel : NSObject

//相片资源
@property (nonatomic, strong) ALAsset *asset;
//选中状态
@property (nonatomic, assign) BOOL isSelected;

@end
