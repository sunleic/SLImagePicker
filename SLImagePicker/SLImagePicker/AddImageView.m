//
//  AddImageView.m
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/6.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "AddImageView.h"
#import "SLSelectImageViewController.h"
#import "AddImageCollectionViewCell.h"
//#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface AddImageView ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation AddImageView{
    
    NSMutableArray *_addPicArr; //从相册或相机中获取的像相片的容器
    UIActivityIndicatorView *_indicatorView; //显示相片保存状态的指示器
    UICollectionView *_collectionView;
    UIImagePickerController *_picker;
    UIViewController *_targetVC;
    
}

- (instancetype)initWithFrame:(CGRect)frame targetViewController:(UIViewController *)target
{
    self = [super initWithFrame:frame];
    if (self) {
        _targetVC = target;
        [self createCellction];
    }
    return self;
}

#pragma mark - 创建collectionView
-(void)createCellction{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.itemSize = CGSizeMake(60, 60);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 305, SCREEN_W - 20, SCREEN_H - 305) collectionViewLayout:flow];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerClass:[AddImageCollectionViewCell class] forCellWithReuseIdentifier:@"addPicCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"AddImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"addPicCell"];
    
    [self addSubview:_collectionView];
}

#pragma mark - UICollectionView协议代理方法的实现

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _addPicArr.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AddImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addPicCell" forIndexPath:indexPath];

    if (indexPath.row == _addPicArr.count) {
        //添加按钮
        cell.imgVIew.image = [UIImage imageNamed:@"addPicBtn"];
        cell.deleteBtn.hidden = YES;
    }else{
        //NSLog(@"------%lu",indexPath.row);
        cell.imgVIew.image = _addPicArr[indexPath.row];
        cell.deleteBtn.hidden = NO;
        cell.deleteBtn.tag = indexPath.row;
        [cell.deleteBtn addTarget:self action:@selector(deleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark -删除已选中的图片
-(void)deleteBtn:(UIButton *)button{
    //NSLog(@"删除按钮被点击了---%lu",button.tag);
    if (_addPicArr.count > 0) {
        [_addPicArr removeObjectAtIndex:button.tag];
        [_collectionView reloadData];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"添加按钮被点击了--%lu-----图片总个数--%lu",indexPath.row,_addPicArr.count);
    if (indexPath.row == _addPicArr.count) {
        [self addPicBtn];
    }
}

-(void)addPicBtn{  //添加说说图片
    //NSLog(@"添加图片");
    if (!_addPicArr) { //初始化容器
        _addPicArr = [NSMutableArray array];
    }
    
//    [_addPicArr removeAllObjects];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"请选择图片提取方式" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"从相册提取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        SLSelectImageViewController *selectedVC = [[SLSelectImageViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:selectedVC];
        selectedVC.maxSelectedCount = 4;

        selectedVC.seletedArrBlock = ^(NSMutableArray *arr){
            
            for (ALAsset *assetTmp in arr) {
                UIImage *image = [UIImage imageWithCGImage:assetTmp.defaultRepresentation.fullScreenImage];
                [_addPicArr addObject:image];
            }
            [_collectionView reloadData];
        };
        
        
//        SLSelectImageViewController *selectedVC = [[SLSelectImageViewController alloc]init];
//        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:selectedVC];
        
        [_targetVC presentViewController:nav animated:YES completion:nil];
    }];
    UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:@"从相机提取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self fetchImageFromCamera];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVC addAction:actionCamera];
    [alertVC addAction:actionPhoto];
    [alertVC addAction:actionCancel];
    
    [_targetVC presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark -调系统摄像头
-(void)fetchImageFromCamera{
    _targetVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = YES; //允许进入相册后对相片的后续操作，不然只能进入相册，不能对相片进行操作而返回
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
        _picker.mediaTypes = temp_MediaTypes;
        [_targetVC presentViewController:_picker animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:@"调取相机失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [_targetVC presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark -相机的相关代理方法
//点击相册具体相片下方的choose按钮调用
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        //NSLog(@"相机右下角的使用照片按钮被点击了");
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]){  //存储由照相机获取的图片
            
            UIImage *newImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            //将照片保存到相册
            [self saveImage:newImage];
            //插入说说照片
            [_addPicArr addObject:newImage];
            [_collectionView reloadData];
        }
    }
    [_targetVC dismissViewControllerAnimated:YES completion:nil];
}

//点击相册导航条右侧的取消按钮或者相机的左下角取消按钮调用
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"Cancel钮被点击了");
    [_targetVC dismissViewControllerAnimated:YES completion:nil];
}


- (void)saveImage:(UIImage *)image{
    
    UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
}


@end
