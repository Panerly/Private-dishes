//
//  DishesDetailVC.m
//  Private dishes
//
//  Created by panerly on 10/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import "DishesDetailVC.h"
#import "GetSize.h"

#import "YYTextExampleHelper.h"
#import "UIImage+YYWebImage.h"
#import "NSString+YYAdd.h"
#import "DishesModel.h"

#import "LEECoolButton.h"

#import "DishesViewController.h"


@interface DishesDetailVC ()
{
    UIButton *backBtn;
    UIImage *thumbnailImage;
    UIImageView *loadingImgView;
    NSURLSessionTask *task;
}
@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, strong) NSMutableArray *imgArr;
@property (nonatomic, strong) NSMutableArray *stepArr;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator ;
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSMutableArray *dishesArr;

@end

@implementation DishesDetailVC

- (NSMutableArray *)imgArr {
    if (!_imgArr) {
        _imgArr = [NSMutableArray array];
    }
    return _imgArr;
}

- (NSMutableArray *)stepArr {
    if (!_stepArr) {
        _stepArr = [NSMutableArray array];
    }
    return _stepArr;
}
- (NSMutableArray *)dishesArr {
    if (!_dishesArr) {
        
        _dishesArr = [NSMutableArray array];
    }
    return _dishesArr;
}


- (YYTextView *)textView {
    
    if (!_textView) {
        _textView = [[YYTextView alloc] initWithFrame:CGRectMake(10, 64, PanScreenWidth-20, PanScreenHeight-64)];
        [self.view addSubview:_textView];
    }
    return _textView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [YYTextExampleHelper addDebugOptionToViewController:self];
    
    if (self.flag) {
        
        NSDictionary *methodDic = [self dictionaryWithJsonString:self.method];
        
        for (NSDictionary *dic in methodDic) {
            
            [self.stepArr addObject:[dic objectForKey:@"step"]];
            [self.imgArr addObject:[dic objectForKey:@"img"]?[dic objectForKey:@"img"]:@""];
        }
    }
    
    [self initTitleView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_flag) {
        
        [self setupTextView];
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
        NSString *fileName = [doc stringByAppendingPathComponent:@"dishes.sqlite"];
        _db = [FMDatabase databaseWithPath:fileName];
        
        if ([_db open]) {
            
            
            FMResultSet *resultSet = [self.db executeQuery:@"select * from dishesTable order by id"];
            
            NSString *nameString;
            while ([resultSet next]) {
                
                nameString  = [resultSet stringForColumn:@"name"];
                
            }
            if (![nameString isEqualToString:self.name]) {
                
                
                [self setupFaveriteBtn];
            }
            
            [_db close];
            
        }
    }else {//
        
        [self _requestData:self.menuId];
    }
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [task cancel];
}

- (void)setupFaveriteBtn {
    
    //星星按钮
    
    LEECoolButton *starButton = [LEECoolButton coolButtonWithImage:[UIImage imageNamed:@"star"] ImageFrame:CGRectMake(10, 10, 40, 40)];
    
    starButton.frame = CGRectMake(PanScreenWidth - 60, PanScreenHeight - 60, 80, 80);
    
    [starButton addTarget:self action:@selector(starButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:starButton];
}

- (void)initTitleView {
    
    _titleView                  = [[TitleView alloc]initWithFrame:CGRectMake(0, 0, PanScreenWidth, 64)];
    _titleView.backgroundColor  = COLORRGB(63, 143, 249);
    _titleView.title            = [NSString stringWithFormat:@"☆ %@ ☆　", _titleStr];
    _titleView.isTranslucent    = NO;
    _titleView.isLeftBtnRotation = YES;
    
    backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBtn.showsTouchWhenHighlighted = YES;
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    _titleView.leftBarButton = backBtn;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    [self.activityIndicator startAnimating];
    
    
    loadingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [loadingImgView setImage:[UIImage sd_animatedGIFNamed:@"loading"]];
    loadingImgView.center = self.textView.center;
    [self.view insertSubview:loadingImgView aboveSubview:self.textView];
    
    _titleView.rightBarButton = (UIButton *)self.activityIndicator;
    
    [self.view addSubview:_titleView];
}
- (void)backAction{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - setupTextView 布置UI

- (void)setupTextView
{
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    
    {
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:self.name];
//        one = [NSMutableAttributedString yy_attachmentStringWithContent:self.name contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(PanScreenWidth, 40) alignToFont:[UIFont boldSystemFontOfSize:30] alignment:YYTextVerticalAlignmentCenter];
        
        one.yy_alignment = NSTextAlignmentCenter;
        one.yy_font = [UIFont boldSystemFontOfSize:30];
        one.yy_color = [UIColor colorWithRed:1.000 green:0.795 blue:0.014 alpha:1.000];
        
        YYTextShadow *shadow = [YYTextShadow new];
        shadow.color = [UIColor colorWithWhite:0.000 alpha:0.20];
        shadow.offset = CGSizeMake(0, -1);
        shadow.radius = 1.5;
        YYTextShadow *subShadow = [YYTextShadow new];
        subShadow.color = [UIColor colorWithWhite:1 alpha:0.99];
        subShadow.offset = CGSizeMake(0, 1);
        subShadow.radius = 1.5;
        shadow.subShadow = subShadow;
        one.yy_textShadow = shadow;
        
        YYTextShadow *innerShadow = [YYTextShadow new];
        innerShadow.color = [UIColor colorWithRed:0.851 green:0.311 blue:0.000 alpha:0.780];
        innerShadow.offset = CGSizeMake(0, 1);
        innerShadow.radius = 1;
        one.yy_textInnerShadow = innerShadow;
        
        [string appendAttributedString:one];
        [string appendAttributedString:[self padding]];
    }
    
    
    // 创建图片图片附件
    NSMutableAttributedString *attachment = [NSMutableAttributedString new];
    
    __weak typeof(self) weakSelf = self;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    thumbnailImage = [UIImage new];
    
    [manager downloadImageWithURL:[NSURL URLWithString:self.thumbnail]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             // progression tracking code
                             NSLog(@"接收到的数据%ld",receivedSize/expectedSize);
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            
                            if (image) {
                                // do something with image
                                thumbnailImage = image;
                            }
                            [UIView animateWithDuration:.5 animations:^{
                                
                                loadingImgView.transform = CGAffineTransformMakeScale(.01, .01);
                            } completion:^(BOOL finished) {
                                
                                [loadingImgView removeFromSuperview];
                                
                            }];
                            [weakSelf showMessage:@"加载完成"];
                            [weakSelf.activityIndicator stopAnimating];
                        }];
    
    
    UIFont *font = [UIFont systemFontOfSize:16];
    attachment = [NSMutableAttributedString yy_attachmentStringWithContent:thumbnailImage contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(PanScreenWidth, 100) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [string appendAttributedString:attachment];
    
    
    {
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n%@\n",self.ingredients]];
        one.yy_font = [UIFont boldSystemFontOfSize:18];
        one.yy_color = [UIColor redColor];
        YYTextShadow *shadow = [YYTextShadow new];
        shadow.color = [UIColor colorWithWhite:0.000 alpha:0.490];
        shadow.offset = CGSizeMake(0, 1);
        shadow.radius = 5;
        one.yy_textShadow = shadow;
        [string appendAttributedString:one];
        
        if (self.ingredients.length > 35) {
            
            [string appendAttributedString:[self padding]];
            [string appendAttributedString:[self padding]];
            [string appendAttributedString:[self padding]];
        }
        [string appendAttributedString:[self padding]];
    }
    
    for (int i = 0; i < _stepArr.count; i++) {
        
        //获取图片大小
        CGSize size = [GetSize getImageSizeWithURL:[NSURL URLWithString:_imgArr[i]]];
        
        //步骤
        {
            NSString *stepString = size.width > PanScreenWidth ? [NSString stringWithFormat:@"\n\n%@\n",_stepArr[i]]: [NSString stringWithFormat:@"\n%@",_stepArr[i]];
            
            NSMutableAttributedString *step = [[NSMutableAttributedString alloc] initWithString:stepString];
            step.yy_font = [UIFont boldSystemFontOfSize:18];
            step.yy_color = [UIColor blackColor];
            YYTextShadow *shadow = [YYTextShadow new];
            shadow.color = [UIColor colorWithWhite:0.000 alpha:0.490];
            shadow.offset = CGSizeMake(0, 1);
            shadow.radius = 5;
            step.yy_textShadow = shadow;
            [string appendAttributedString:step];
        }
        
        
        // 创建图片附件
        NSMutableAttributedString *attach = [NSMutableAttributedString new];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_imgArr[i]]]];
        
        if ([_imgArr[i] isEqualToString:@""]) {
            
            attach = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(0, 0) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            [string appendAttributedString:attach];
        } else {
            
            [string appendAttributedString:[self padding]];
            [string appendAttributedString:[self padding]];
            [string appendAttributedString:[self padding]];
            [string appendAttributedString:[self padding]];
            attach = [NSMutableAttributedString yy_attachmentStringWithContent:[self OriginImage:image scaleToSize:CGSizeMake(250, 180)] contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(PanScreenWidth, PanScreenWidth/3) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            [string appendAttributedString:attach];
            [string appendAttributedString:[self padding]];
            [string appendAttributedString:[self padding]];
            
//            //如果照片宽比屏幕宽则约束
//            if (size.width > PanScreenWidth-40 || size.height >PanScreenWidth -40) {
//                attach = [NSMutableAttributedString yy_attachmentStringWithContent:[self OriginImage:image scaleToSize:CGSizeMake(250, 180)] contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(PanScreenWidth, PanScreenWidth/3) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
//                [string appendAttributedString:attach];
//                [string appendAttributedString:[self padding]];
//                [string appendAttributedString:[self padding]];
//            }else {
//                
//                attach = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(PanScreenWidth, PanScreenWidth/3) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
//                [string appendAttributedString:attach];
//            }
        }
    }
    
    //总结
//    {
//        [string appendAttributedString:[self padding]];
//        [string appendAttributedString:[self padding]];
//        
//        NSMutableAttributedString *sumaryString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.sumary]];
//        sumaryString.yy_font = [UIFont boldSystemFontOfSize:20];
//        sumaryString.yy_color = [UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000];
//        sumaryString.yy_lineSpacing = 12;
//        
//        YYTextBorder *border = [YYTextBorder new];
//        border.strokeColor = [UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000];
//        border.strokeWidth = 3;
//        border.lineStyle = YYTextLineStylePatternSolid;
//        border.cornerRadius = 3;
//        border.insets = UIEdgeInsetsMake(0, -4, 0, -4);
//        sumaryString.yy_textBackgroundBorder = border;
//        
//        [string appendAttributedString:[self padding]];
//        [string appendAttributedString:sumaryString];
//        [string appendAttributedString:[self padding]];
//        [string appendAttributedString:[self padding]];
//        [string appendAttributedString:[self padding]];
//        [string appendAttributedString:[self padding]];
//    }
    {
        
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:[self padding]];
        NSMutableAttributedString *sumaryString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"短评:%@",self.sumary]];
        sumaryString.yy_font = [UIFont boldSystemFontOfSize:20];
        sumaryString.yy_color = [UIColor redColor];
        sumaryString.yy_lineSpacing = 12;
        
        YYTextBorder *border = [YYTextBorder new];
        border.cornerRadius = 50;
        border.insets = UIEdgeInsetsMake(0, -10, 0, -10);
        border.strokeWidth = 0.5;
        border.strokeColor = sumaryString.yy_color;
        border.lineStyle = YYTextLineStyleSingle;
        sumaryString.yy_textBackgroundBorder = border;
        
        YYTextBorder *highlightBorder = border.copy;
        highlightBorder.strokeWidth = 0;
        highlightBorder.strokeColor = sumaryString.yy_color;
        highlightBorder.fillColor = sumaryString.yy_color;
        
//        YYTextHighlight *highlight = [YYTextHighlight new];
//        [highlight setColor:[UIColor whiteColor]];
//        [highlight setBackgroundBorder:highlightBorder];
//        [sumaryString yy_setTextHighlight:highlight range:sumaryString.yy_rangeOfAll];
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:sumaryString];
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:[self padding]];
    }
    
    self.textView.attributedText = string;
    self.textView.editable = NO;
    self.textView.showsVerticalScrollIndicator = NO;
    
    
}


- (void)starButtonAction:(LEECoolButton *)sender{
    
    if (sender.selected) {
        //未选中状态
        [sender deselect];
        [self saveToLocalDB:NO];
    } else {
        //选中状态
        [sender select];
        [self saveToLocalDB:YES];
    }
}

- (void)saveToLocalDB :(BOOL)isFavorite {
    
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    thumbnailImage = [UIImage new];
    
    [manager downloadImageWithURL:[NSURL URLWithString:self.thumbnail]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            
                            if (image) {
                                // do something with image
                                thumbnailImage = image;
                            }
                        }];

    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"dishes.sqlite"];
    _db = [FMDatabase databaseWithPath:fileName];
    
    if (isFavorite) {//收藏进本地数据库
        
        NSData *imgData = UIImageJPEGRepresentation(thumbnailImage, 1);
        if ([_db open]) {
            
            
            FMResultSet *resultSet = [self.db executeQuery:@"select * from dishesTable order by id"];
            
            NSString *nameString;
            while ([resultSet next]) {
                
                nameString  = [resultSet stringForColumn:@"name"];
                
            }
            if ([nameString isEqualToString:self.name]) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已经收藏过了哟(⊙ω⊙)" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            }else {
                
                [self.db executeUpdate:@"create table if not exists dishesTable (id integer primary key autoincrement, name text null,  img text null, menuId text null, titleStr text null);"];
                [self.db executeUpdate:@"insert into dishesTable (name, img, menuId, titleStr) values (?,?,?,?);",self.name, imgData, self.menuId, self.titleView.title];
                [self showMessage:@"已收藏"];
            }
            
            [_db close];
            
        }
    }else {//从本地数据库删除
        
        if ([_db open]) {
            
            [self.db executeUpdate:@"create table if not exists dishesTable (id integer primary key autoincrement, name text null,  image text null);"];
            [self.db executeUpdate:@"delete from dishesTable where name = '%@'",self.name];
            [self.db executeUpdate:@"delete from dishesTable where menuId = '%@'",self.menuId];
            [self.db executeUpdate:@"delete from dishesTable where titleStr = '%@'",self.titleView.title];
            [_db executeUpdate:[NSString stringWithFormat:@"delete from dishesTable where img = '%@'",thumbnailImage]];
            
            [_db close];
            [self showMessage:@"已取消收藏"];
        }
    }
}

//添加转行
- (NSAttributedString *)padding {
    
    NSMutableAttributedString *pad = [[NSMutableAttributedString alloc] initWithString:@"\n\n"];
    
    pad.yy_font = [UIFont systemFontOfSize:4];
    
    return pad;
}
//字符串转化成字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
   
    if (jsonString == nil) {
        
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];  
    
    if(err) {  
        
        NSLog(@"json解析失败：%@",err);  
        return nil;
    }
    
    return dic;  
}

//- (NSString *)transformString :(NSString *)originalString{
//    //1. 去掉首尾空格和换行符
//    originalString = [originalString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    //2. 去掉所有空格和换行符
//    originalString = [originalString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    originalString = [originalString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    return originalString;
//}

- (UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image{
    //Do something with the downloaded image
    
    
    [self.activityIndicator stopAnimating];
}

- (void)showMessage:(NSString *)msg {
    
    CGFloat padding = 10;
    
    YYLabel *label = [YYLabel new];
    label.text = msg;
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.033 green:0.685 blue:0.978 alpha:0.730];
    label.width = self.view.width;
    label.textContainerInset = UIEdgeInsetsMake(padding, padding, padding, padding);
    label.height = [msg heightForFont:label.font width:label.width] + 2 * padding;
    
    label.bottom = (kiOS7Later ? 64 : 0);
//    [self.view addSubview:label];
    [self.view insertSubview:label belowSubview:self.titleView];
    [UIView animateWithDuration:0.3 animations:^{
        label.top = (kiOS7Later ? 64 : 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            label.bottom = (kiOS7Later ? 64 : 0);
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
}



- (void)_requestData :(NSString *)menuId {
    
    [task cancel];
    
    NSString *logInUrl = [NSString stringWithFormat:@"http://apicloud.mob.com/v1/cook/menu/query"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *parameter = @{
                                @"key":@"158556148371e",
                                @"id":self.menuId
                                };
    
    task =[manager POST:logInUrl parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [weakSelf.dishesArr removeAllObjects];
            
            if ([[responseObject objectForKey:@"msg"] isEqualToString:@"success"]) {
                
                NSMutableDictionary *responseDic = [responseObject objectForKey:@"result"];
                
                
                self.thumbnail = [responseDic objectForKey:@"thumbnail"];
                self.img = [[responseDic objectForKey:@"recipe"] objectForKey:@"img"];
                self.ingredients = [[responseDic objectForKey:@"recipe"] objectForKey:@"ingredients"];
                self.method = [[responseDic objectForKey:@"recipe"] objectForKey:@"method"];
                self.sumary = [[responseDic objectForKey:@"recipe"] objectForKey:@"sumary"];
                self.name = [[responseDic objectForKey:@"recipe"] objectForKey:@"title"];;
        
                }
            }else if ([[responseObject objectForKey:@"retCode"] isEqualToString:@"20201"]) {
                UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"查询不到数据！" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertVC addAction:confir];
                
                [weakSelf presentViewController:alertVC animated:YES completion:^{
                    
                }];
            }else if ([[responseObject objectForKey:@"retCode"] isEqualToString:@"20202"]) {
                UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"菜谱id不合法！" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertVC addAction:confir];
                
                [weakSelf presentViewController:alertVC animated:YES completion:^{
                    
                }];
            }
        
        [self setupData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        [weakSelf.activityIndicator stopAnimating];
        
        NSLog(@"错误信息：%@",error);
        
        UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        if (error.code == -1001) {
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请求超时!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:confir];
            
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [weakSelf presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
    
}

- (void)setupData {
    
    
    NSDictionary *methodDic = [self dictionaryWithJsonString:self.method];
    
    for (NSDictionary *dic in methodDic) {
        
        [self.stepArr addObject:[dic objectForKey:@"step"]];
        [self.imgArr addObject:[dic objectForKey:@"img"]?[dic objectForKey:@"img"]:@""];
    }
    
    [self setupTextView];
}



//添加预览界面的ActionSheet
-(NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    
    UIPreviewAction * collectAction = [UIPreviewAction actionWithTitle:@"collect " style:0 handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        [self _requestData:self.menuId];
        [self saveToLocalDB:YES];
        NSLog(@"click2");
    }];
    UIPreviewAction * closeAction = [UIPreviewAction actionWithTitle:@"close" style:0 handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        NSLog(@"click3");
    }];
    
    NSArray * actions = @[collectAction,closeAction];
    return actions;
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
