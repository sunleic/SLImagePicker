//
//  ViewController.m
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/3.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "ViewController.h"
#import "SLMultiSelectImagesVC.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AddImageView.h"

typedef NS_ENUM(NSInteger,SLFecthcPictureType) {

    SLFecthcPictureTypePhotos,
    SLFecthcPictureTypeCamera
};

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ViewController{
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, 100, 100, 40)];
    [button setTitle:@"获取照片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(fetchImage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:button];
    
    AddImageView *addimgView = [[AddImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) targetViewController:self];
    
    [self.view addSubview:addimgView];
    
}

- (void)fetchImage:(UIButton*)button{
    
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"获取照片" message:@"按以下两种方式获取照片" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *photos = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self fetchImageWithType:SLFecthcPictureTypePhotos];
    }];
    
    [alertCtl addAction:photos];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self fetchImageWithType:SLFecthcPictureTypeCamera];
    }];
    
    [alertCtl addAction:camera];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertCtl addAction:cancel];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
}

#pragma mark -获取相册
-(void)fetchImageWithType:(SLFecthcPictureType)fecthcPictureType{
    
    ////判断授权状态
    NSString *tipTextWhenNoPhotosAuthorization; // 提示语
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        // 展示提示语
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:tipTextWhenNoPhotosAuthorization preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:ok];
        
        [self presentViewController:alertVC animated:YES completion:nil];
        
        return;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
