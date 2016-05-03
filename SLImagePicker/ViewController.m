//
//  ViewController.m
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/3.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "ViewController.h"

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
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 40)];
    [button setTitle:@"获取照片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(fetchImage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:button];
    
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
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    //允许进入相册后对相片的后续操作，不然只能进入相册，不能对相片进行操作而返回
    imagePicker.allowsEditing = YES;
    
    switch (fecthcPictureType) {
        case SLFecthcPictureTypePhotos:
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
            
        case SLFecthcPictureTypeCamera:
        {
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
                imagePicker.mediaTypes = temp_MediaTypes;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:@"调取相机失败" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark -相册，相机的相关代理方法
//点击相册具体相片下方的choose按钮调用
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {//NSLog(@"相册的choose按钮被点击了");
        //设置图片可以编辑
        //info 存储图片的所有信息 , 获取编辑后的图片
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //将被选择的图片大小做下修改
        //UIImage *newImage = [[ImageTool shareTool]resizeImageToSize:CGSizeMake(50, 50) sizeOfImage:image];
        
//        [_addPicArr addObject:image];
//        [_collectionView reloadData];
        
    }else if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        //NSLog(@"相机右下角的使用照片按钮被点击了");
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]){  //存储由照相机获取的图片
            
            UIImage *newImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            //将照片保存到相册
            [self saveImage:newImage];
//            //插入说说照片
//            [_addPicArr addObject:newImage];
//            [_collectionView reloadData];
            
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//点击相册导航条右侧的取消按钮或者相机的左下角取消按钮调用
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"Cancel钮被点击了");
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)saveImage:(UIImage *)image{
    
    UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
