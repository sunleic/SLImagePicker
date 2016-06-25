//
//  AddImageView.m
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/6.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "AddImageView.h"
#import "SLMultiSelectImagesVC.h"
#import "AddImageCollectionViewCell.h"
#import "SLCollectionModel.h"
//#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface AddImageView ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

//装载相册图片的asset
@property (nonatomic, strong) NSMutableArray *imageAssetsArr;
//相册资源库
@property (nonatomic, strong) ALAssetsLibrary* assetsLibrary;

//相册中的最后一张照片的model
@property (nonatomic, strong) SLCollectionModel *lastImageModel;

@end

@implementation AddImageView{
    
    NSMutableArray *_addPicArr; //从相册或相机中获取的像相片的容器，装的是已经选择照片的SLCollectionModel
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
    flow.itemSize = CGSizeMake((SCREEN_W - 20 -8)/5, (SCREEN_W - 20 - 8)/5);
    flow.minimumInteritemSpacing = 1.5;
    flow.minimumLineSpacing = 1.5;
    
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

        SLCollectionModel *modelT = _addPicArr[indexPath.row];;
        cell.imgVIew.image = [UIImage imageWithCGImage:modelT.asset.defaultRepresentation.fullScreenImage];
       
        
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

#pragma mark - 添加图片
-(void)addPicBtn{  //添加说说图片
    //NSLog(@"添加图片");
    if (!_addPicArr) { //初始化容器
        _addPicArr = [NSMutableArray array];
    }
    
    if (_addPicArr.count > 8) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"选择图片的个数不能大于9张！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
        [_targetVC presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"请选择图片提取方式" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"从相册提取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        SLMultiSelectImagesVC *selectedVC = [[SLMultiSelectImagesVC alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:selectedVC];
        selectedVC.maxSelectedCount = 9;
        

        selectedVC.seletedArrBlock = ^(NSMutableArray *arr){
            //讲原来的已经选中的图片清空
            [_addPicArr removeAllObjects];
            for (SLCollectionModel *modelTmp in arr) {
                [_addPicArr addObject:modelTmp];
            }
            [_collectionView reloadData];
        };
        
        //当图片需要二次选择时，将已经选择的图片再现到图片选择器中
        if (_addPicArr.count > 0) {
            //将多选框的已经选中的照片数据源清空
            [selectedVC.arraySelectedImageAssets removeAllObjects];
            for (SLCollectionModel *model  in _addPicArr) {
                [selectedVC.arraySelectedImageAssets addObject:model];
            }
        }
        
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
            //将原照片保存到相册，要确保照片保存完之后，在去最后一张图片，不然读到只可能是倒数第二张
            [self saveImage:newImage];
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
    
    //第三个参数是固定的，不能随意更改
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{

    if (error != NULL)
    {
        NSLog(@"+++相册保存失败++");
    }else{
        
        //获取刚刚照的照片对应的model
        [self fetchLastImagesFromLibrary];
    }
}


#pragma mark -获取相册的最后一张照片
- (void)fetchLastImagesFromLibrary{
    
    if (!_imageAssetsArr) {
        _imageAssetsArr = [NSMutableArray array];
    }
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"------++++++++---");
        //执行遍历
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//遍历获取相册的组的block回调
            if (group) {
                //获取相簿的组
                NSString *groupStr = [NSString stringWithFormat:@"%@",group];
                NSString *g1 = [groupStr substringFromIndex:16] ;
                NSArray *arrTmp = [NSArray new];
                arrTmp = [g1 componentsSeparatedByString:@","];
                NSString *groupNameStr = [[[arrTmp objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1];
                
                //NSLog(@"IIIII____%lu",group.numberOfAssets);
                
                if ([groupNameStr isEqualToString:@"Camera Roll"] || [groupNameStr isEqualToString:@"相机胶卷"]) {  //只获取camera roll的照片
                    //执行遍历，用对应的block遍历相册资源asset
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) { //遍历获取对应组的照片asset
                        
                        if (result) {
                            NSLog(@"index++++%lu",index);
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) { //如果资源是照片的话
                                //
                                SLCollectionModel *model = [[SLCollectionModel alloc]init];
                                
                                model.asset = result;
                                model.isSelected = NO;
                                
                                [weakSelf.imageAssetsArr addObject:model];
                            }
                        }else{ //当照片加载完成的时候，最后的一次遍历group=nil
                            NSLog(@"index----%lu",index);
                            _lastImageModel = [weakSelf.imageAssetsArr lastObject];

                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                //将上一步保存的的照片的对应的model存到数组中
                                if (_lastImageModel) {
                                    _lastImageModel.isSelected = YES;
                                    [_addPicArr addObject:_lastImageModel];
                                }
                                
                                [_collectionView reloadData];
                                
                            });
                        }
                    }];
                }
            }
        } failureBlock:^(NSError *error) {//访问相册失败的block回调
            
            NSLog(@"相册访问失败 =%@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"访问相册失败，请检查对本APP的相册访问权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                
                [alertView show];
            });
            
        }];
    });
}


#pragma mark -相册资源库
-(ALAssetsLibrary *)assetsLibrary{
    
    if (_assetsLibrary == nil) {
        _assetsLibrary = [AddImageView defaultAssetsLibrary];
    }
    return _assetsLibrary;
}

#pragma mark -ALAssetsLibrary 相薄单例
+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

@end
