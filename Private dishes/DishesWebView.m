//
//  DishesWebView.m
//  Private dishes
//
//  Created by panerly on 16/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import "DishesWebView.h"
#import "TitleView.h"
#import <WebKit/WebKit.h>

@interface DishesWebView ()<UIWebViewDelegate>

{
    UIButton *backBtn;
    UIImageView *loadingView;
}

@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation DishesWebView

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadWebView];
    
    [self initTitleView];
    
    
    NSLog(@"请求的菜谱名为：%@",self.name);
}

- (void)loadWebView {
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight - 64)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://60.205.59.95/v1/dish/search?pg=3&word=%@", self.name]]];
    
    NSLog(@"搜索URL为：http://60.205.59.95/v1/dish/search?pg=3&word=%@",self.name);
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.webView];
}

- (void)initTitleView {
    
    _titleView                  = [[TitleView alloc]initWithFrame:CGRectMake(0, 0, PanScreenWidth, 64)];
    _titleView.backgroundColor  = COLORRGB(63, 143, 249);
    _titleView.title            = [NSString stringWithFormat:@"☆ %@ ☆　", self.name];
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
    
    
    loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [loadingView setImage:[UIImage sd_animatedGIFNamed:@"loading"]];
    loadingView.center = self.webView.center;
    [self.view insertSubview:loadingView aboveSubview:self.webView];
    
    _titleView.rightBarButton = (UIButton *)self.activityIndicator;
    
    [self.view addSubview:_titleView];
}

- (void)backAction{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIWebViewdelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [loadingView removeFromSuperview];
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
