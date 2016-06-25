//
//  SLMultiSelectImagesVC.m
//  SLImagePicker
//
//  Created by 孙磊 on 16/5/4.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "SLMultiSelectImagesVC.h"
#import "SLCollectionViewCell.h"
#import "SLCollectionModel.h"
//#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface SLMultiSelectImagesVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

//图片的asset
@property (nonatomic, strong) NSMutableArray *arrayImageAssets;

//确定按钮
@property (nonatomic, strong) UIButton *doneBtn;

//是否选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

//原图选择按钮
@property (nonatomic, strong)  UIButton *btnOriginalPhoto;

//所选择原图的总共大小
@property (nonatomic, strong)  UILabel *labPhotosBytes;

//相册资源库
@property (nonatomic, strong) ALAssetsLibrary* assetsLibrary;

@end

@implementation SLMultiSelectImagesVC

#warning 日了狗了，没有被调用(原因竟是使用了defaultSelectImageVC单例方法)
-(void)dealloc{
    
    NSLog(@"*******%s",__func__);

    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //默认选择图片的最大数为3
    if (self.maxSelectedCount == 0) {
        self.maxSelectedCount = 3;
    }
    
    [self updateToolView];
    
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0.1)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    [self fetchImagesFromLibrary];
}

-(void)dismissVC{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -获取相册的所有图片
- (void)fetchImagesFromLibrary{
    
    //做相册授权判断
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        
        NSString *displayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        
        NSString *tips = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册",displayName];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:tips preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //可以跳转到设置
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
            
        }];
        
        [alertVC addAction:cancel];
        [self presentViewController:alertVC animated:YES completion:nil];
        
        return;
    }
    
    
    if (!_arrayImageAssets) {
        _arrayImageAssets = [NSMutableArray array];
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([groupNameStr isEqualToString:@"Camera Roll"] || [groupNameStr isEqualToString:@"相机胶卷"]) {
                        self.navigationItem.title = @"相机胶卷";
                    }
                });
                NSLog(@"------++++++++---%@",group);
                //组的name
                //NSString *groupName = groupNameStr;
                
                if ([groupNameStr isEqualToString:@"Camera Roll"] || [groupNameStr isEqualToString:@"相机胶卷"]) {  //只获取camera roll的照片
                    NSLog(@"adjflakdjfasdfjkl");
                    //执行遍历，用对应的block遍历相册资源asset
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) { //遍历获取对应组的照片asset
                        if (result) {
                            NSLog(@"result=-------");
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) { //如果资源是照片的话
                                //
                                SLCollectionModel *model = [[SLCollectionModel alloc]init];
                                
                                model.asset = result;
                                model.isSelected = NO;
                                
                                [weakSelf.arrayImageAssets addObject:model];
                            }
                        }else{ //当照片加载完成的时候，最后的一次遍历group=nil
                            NSLog(@"result=-------++++");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if ([groupNameStr isEqualToString:@"Camera Roll"] || [groupNameStr isEqualToString:@"相机胶卷"]) {
                                    
                                    //将已经选中的图片重现到图片选择器上
                                    if (self.arraySelectedImageAssets.count > 0) {
                                        
                                        for (id modelTmp in self.arraySelectedImageAssets) {
                                            
                                            if ([modelTmp isKindOfClass:[SLCollectionModel class]]) {
                                                
                                                SLCollectionModel *modelT = modelTmp;
                                                
                                                NSString *str1 = [NSString stringWithFormat:@"%@",modelT.asset.defaultRepresentation.url];
                                                NSLog(@"++++++++long---%d",modelT.isSelected);
                                                for (SLCollectionModel *tmp in self.arrayImageAssets) {
                                                    NSString *str2 = [NSString stringWithFormat:@"%@",tmp.asset.defaultRepresentation.url];
                                                    if ([str1 isEqualToString:str2]) {
                                                        tmp.isSelected = YES;
                                                    }
                                                    NSLog(@"*******long****%d",tmp.isSelected);
                                                }
                                                
                                            }
                                        }
                                    }
                                    //创建图片选择器
                                    [weakSelf createContents];
                                    [weakSelf updateToolView];
                                }
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

#pragma mark - 创建相册选择器
- (void)createContents{
    NSLog(@"创建相册");
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    layout.itemSize = CGSizeMake((SCREEN_W-9)/4, (SCREEN_W-9)/4);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);

    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H - 64 - 50) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView setDelaysContentTouches:NO];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[SLCollectionViewCell class] forCellWithReuseIdentifier:@"reuseID"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SLCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"reuseID"];
    
    [self.view addSubview:self.collectionView];
    
    //创建下面的工具条
    
    UIImageView *toolView = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_H - 50 - 64, SCREEN_W, 50)];
    toolView.userInteractionEnabled = YES;
    
    UILabel *lineLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 1.5)];
    lineLbl.backgroundColor = [UIColor colorWithRed:105/255.0 green:189/255.0 blue:0 alpha:1];
    
    
    UIButton *reviewBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 40, 30)];
    [reviewBtn setTitle:@"预览" forState:UIControlStateNormal];
    reviewBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [reviewBtn setTitleColor:[UIColor colorWithRed:105/255.0 green:189/255.0 blue:0 alpha:1] forState:UIControlStateNormal];
    [reviewBtn addTarget:self action:@selector(reviewBtn) forControlEvents:UIControlEventTouchUpInside];
    
    _doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_W - 65, 10, 60, 30)];
    _doneBtn.layer.cornerRadius = 6;
    _doneBtn.layer.masksToBounds = YES;
    [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_doneBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:105/255.0 green:189/255.0 blue:0 alpha:1]] forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(doneBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolView addSubview:lineLbl];
    [toolView addSubview:reviewBtn];
    [toolView addSubview:_doneBtn];
    
    [self.view addSubview:toolView];
    
}

-(void)updateToolView{
    
    [_doneBtn setTitle:[NSString stringWithFormat:@"%@(%lu)",@"确定",self.arraySelectedImageAssets.count] forState:UIControlStateNormal];
}

- (UIImage *)imageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark -预览
-(void)reviewBtn{
    NSLog(@"预览");
}

#pragma mark -回传选中的图片
-(void)doneBtn:(UIButton *)button{
    NSLog(@"回传选中的图片");
    self.seletedArrBlock(self.arraySelectedImageAssets);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"相片的个数++++%lu",_arrayImageAssets.count);
    return _arrayImageAssets.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    SLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseID" forIndexPath:indexPath];
    
    SLCollectionModel *model = _arrayImageAssets[indexPath.row];
    
    cell.imgView.image = [UIImage imageWithCGImage:model.asset.thumbnail];
    cell.imgView.backgroundColor = [UIColor purpleColor];
    cell.imgView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imgView.clipsToBounds = YES;
    
    cell.btnSelect.selected = model.isSelected;
    cell.btnSelect.tag = indexPath.row;
    [cell.btnSelect addTarget:self action:@selector(imageClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - 选中照片
- (void)imageClick:(UIButton *)btn{
    
    if (self.arraySelectedImageAssets.count >= self.maxSelectedCount && btn.selected == NO) {
        [self promptWithTitle:@"提示" message:[NSString stringWithFormat:@"选择照片不能超过%lu张！",self.maxSelectedCount]];
        return;
    }
    
    SLCollectionModel *model = _arrayImageAssets[btn.tag];
    NSString *imgUrlStr = [NSString stringWithFormat:@"%@",model.asset.defaultRepresentation.url];
    
    if (!btn.selected) { //添加图片,默认的照片按钮都没选中
        //添加图片到选中数组
        model.isSelected = YES;
        [self.arraySelectedImageAssets addObject:model];
        
    } else {   //移除图片
        for (SLCollectionModel *modelTmp in self.arraySelectedImageAssets) {
            
            NSString *imgUrlStrTmp = [NSString stringWithFormat:@"%@",modelTmp.asset.defaultRepresentation.url];
            if ([imgUrlStrTmp isEqualToString:imgUrlStr]) {
                [self.arraySelectedImageAssets removeObject:modelTmp];
                break;
            }
        }
    }
    
    btn.selected = !btn.selected;
    
    [self updateToolView];
    //    NSLog(@"---选中的照片---%@",self.arraySelectedImageAssets);
}

-(void)promptWithTitle:(NSString *)titile message:(NSString *)message{

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:titile message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:ok];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark -被选中的相册容器
-(NSMutableArray *)arraySelectedImageAssets{
    
    if (_arraySelectedImageAssets == nil) {
        _arraySelectedImageAssets = [NSMutableArray array];
    }
    return _arraySelectedImageAssets;
}

#pragma mark -相册资源库
-(ALAssetsLibrary *)assetsLibrary{

    if (_assetsLibrary == nil) {
        _assetsLibrary = [SLMultiSelectImagesVC defaultAssetsLibrary];
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

#pragma mark - 多选视图控制器单例
+ (SLMultiSelectImagesVC *)defaultSelectImageVC{

    static dispatch_once_t token = 0;
    static SLMultiSelectImagesVC *selectImageVC;
    dispatch_once(&token, ^{
        selectImageVC = [[SLMultiSelectImagesVC alloc] init];
    });
    return selectImageVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
