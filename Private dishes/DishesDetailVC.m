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


@interface DishesDetailVC ()
{
    UIButton *backBtn;
    UIImage *thumbnailImage;
    UIImageView *loadingImgView;
}
@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, strong) NSMutableArray *imgArr;
@property (nonatomic, strong) NSMutableArray *stepArr;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator ;

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
    
    NSDictionary *methodDic = [self dictionaryWithJsonString:self.method];
    
    for (NSDictionary *dic in methodDic) {
        
        [self.stepArr addObject:[dic objectForKey:@"step"]];
        [self.imgArr addObject:[dic objectForKey:@"img"]?[dic objectForKey:@"img"]:@""];
    }

    [self initTitleView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupTextView];
}


- (void)initTitleView {
    
    _titleView                  = [[TitleView alloc]initWithFrame:CGRectMake(0, 0, PanScreenWidth, 64)];
    _titleView.backgroundColor  = COLORRGB(63, 143, 249);
    _titleView.title            = [NSString stringWithFormat:@"☆ %@ ☆　", self.titleStr];
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
    loadingImgView.center = self.view.center;
    [self.view insertSubview:loadingImgView aboveSubview:self.textView];
    
    _titleView.rightBarButton = (UIButton *)self.activityIndicator;
    
    [self.view addSubview:_titleView];
}
- (void)backAction{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


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
                            [weakSelf.activityIndicator stopAnimating];
                        }];
    
//    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.thumbnail]]];
    
    UIFont *font = [UIFont systemFontOfSize:16];
    attachment = [NSMutableAttributedString yy_attachmentStringWithContent:thumbnailImage contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(PanScreenWidth, 100) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [string appendAttributedString:attachment];
    
    
    {
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n食材：\n%@\n",self.ingredients]];
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
        
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:[UIColor whiteColor]];
        [highlight setBackgroundBorder:highlightBorder];
        [sumaryString yy_setTextHighlight:highlight range:sumaryString.yy_rangeOfAll];
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:sumaryString];
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:[self padding]];
        [string appendAttributedString:[self padding]];
    }
    
    self.textView.attributedText = string;
    self.textView.editable = NO;
}

- (NSAttributedString *)padding {
    
    NSMutableAttributedString *pad = [[NSMutableAttributedString alloc] initWithString:@"\n\n"];
    
    pad.yy_font = [UIFont systemFontOfSize:4];
    
    return pad;
}

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
