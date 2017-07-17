//
//  DishesViewController.m
//  Private dishes
//
//  Created by panerly on 10/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import "DishesViewController.h"
#import "JJPopoverView.h"
#import "HomeCollectionViewCell.h"
#import "DishesFlowLayout.h"
#import "DishesModel.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "DishesDetailVC.h"
#import "MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "HyRoundMenuView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DishesWebView.h"
#import "XRCarouselView.h"
#import "SDCycleScrollView.h"


static NSString *const DishCellIdentifier = @"dishesCellIdentifier";
// 音频文件的ID
static SystemSoundID shake_sound_male_id = 0;

static NSString *headerViewIdentifier = @"hederview";

@interface DishesViewController ()
<
JJPopoverViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UISearchBarDelegate,
HyRoundMenuViewDelegate,
UIViewControllerPreviewingDelegate
>
{
    NSURLSessionTask *task;
    UIImageView *loading;
    UISearchBar *customSearchBar;
    NSString *totalCount;
}

/** 所有的美食数据 */
@property (nonatomic, strong) NSMutableArray *searchData;// 保存搜索结果数据的NSArray对象。

@property (nonatomic, weak) JJPopoverView *popover;

@property (nonatomic, strong) NSArray *titlesArr;

@property (nonatomic, weak) UICollectionView *collectionView;


@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) HyRoundMenuView *menuView;

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@end

@implementation DishesViewController

- (NSMutableArray *)searchData {
    if (!_searchData) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initRightBarItem];
    
    [self initCarouseView];

    
    [self setUpLayout];
    
    [self setupRefresh];
    
    // 第一次刷新手动调用
    [self.collectionView.mj_header beginRefreshing];
    
    [self setMenu];
    
    //检测是否支持3D Touch...
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        
        //注册
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    
    [self setupEffectView];
}

//轮播图
- (void)initCarouseView {
    
    NSArray *arr = @[
                     [UIImage imageNamed:@"002.jpg"],
                     [UIImage imageNamed:@"001.jpg"],
                     @"003.jpg",
                     gifImageNamed(@"004.gif")
                     ];
    _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, PanScreenWidth, 180) shouldInfiniteLoop:YES imageNamesGroup:arr];
    //_cycleScrollView.delegate = self;
    _cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    //[demoContainerView addSubview:cycleScrollView];
    _cycleScrollView.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupEffectView{
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.visualEffectView.frame = CGRectMake(0, 64, PanScreenWidth, PanScreenHeight - 64);
    [self.view addSubview:self.visualEffectView];
    self.visualEffectView.alpha = 0;
    
    //监听键盘弹出的方式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.menuView.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.menuView.hidden = YES;
}

- (void)setMenu {
    
    _menuView = [HyRoundMenuView shareInstance];
    
    _data = @[
              [HyRoundMenuModel title:@"炖"  iconImage:[UIImage imageNamed:@"01"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge],
              [HyRoundMenuModel title:@"蒸"      iconImage:[UIImage imageNamed:@"02"] transitionType:HyRoundMenuModelTransitionTypeNormal],
              [HyRoundMenuModel title:@"烩"  iconImage:[UIImage imageNamed:@"03"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge],
              [HyRoundMenuModel title:@"熏"        iconImage:[UIImage imageNamed:@"04"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge],
              [HyRoundMenuModel title:@"卤"   iconImage:[UIImage imageNamed:@"05"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge],
              [HyRoundMenuModel title:@"红烧"       iconImage:[UIImage imageNamed:@"06"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge],
              [HyRoundMenuModel title:@"焖"       iconImage:[UIImage imageNamed:@"07"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge],
              [HyRoundMenuModel title:@"炒"       iconImage:[UIImage imageNamed:@"08"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge],
              [HyRoundMenuModel title:@"煎"       iconImage:[UIImage imageNamed:@"09"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge],
              [HyRoundMenuModel title:@"炸"       iconImage:[UIImage imageNamed:@"10"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge]
              ].mutableCopy;
    
    _menuView.bigRadius   = 120.0f;
    _menuView.smallRadius = 30.0f;
    HyRoundMenuModel *centerModel = [HyRoundMenuModel title:@"please select way to cook" iconImage:[UIImage imageNamed:@"float_btn"] transitionType:HyRoundMenuModelTransitionTypeMenuEnlarge];
    centerModel.type = HyRoundMenuModelItmeTypeCenter;
    [_data addObject:centerModel];
    _menuView.dataSources = _data;
    UIColor *color = [UIColor colorWithRed:18.f/255.f green:58.f/255.f blue:53.f/255.f alpha:1.0f];
    //UIColor *color2 = [UIColor colorWithWhite:1 alpha:0.2];
    _menuView.shapeColor = color;
    
    _menuView.backgroundViewType = HyRoundMenuViewBackgroundViewTypeBlur;
    _menuView.customBackgroundViewColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    _menuView.delegate = self;
}
#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

// 初始化collectionView
- (void)setUpLayout{
    
    // 创建布局
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    // 设置列的最小间距
    _flowLayout.minimumInteritemSpacing = 10;
    
    // 设置每个item的大小
    _flowLayout.itemSize = CGSizeMake(PanScreenWidth/3-20, PanScreenWidth/3);
    
    // 设置最小行间距
    _flowLayout.minimumLineSpacing = 15;
    
    // 设置布局的内边距
    _flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    
    // 滚动方向
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
     _flowLayout.headerReferenceSize=CGSizeMake(self.view.frame.size.width, 180); //设置collectionView头视图的大小
    
    // 创建CollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight-64) collectionViewLayout:_flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate   = self;
    [self.view addSubview:collectionView];
    
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:DishCellIdentifier];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    //注册头视图
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier];
    
    
    
    CGRect mainViewBounds = self.navigationController.view.bounds;
    customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainViewBounds)/2-((CGRectGetWidth(mainViewBounds)-120)/2), CGRectGetMinY(mainViewBounds)+22, CGRectGetWidth(mainViewBounds)-120, 40)];
    
    customSearchBar.delegate = self;
    customSearchBar.showsCancelButton = NO;
    customSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    customSearchBar.placeholder = @"search any ingredients";
    
    [self.navigationController.view addSubview: customSearchBar];
    
    //设置刷新view
    loading        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loading.center = self.collectionView.center;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"loading"];
    [loading setImage:image];
    [self.view insertSubview:loading aboveSubview:self.collectionView];
    
}



NSUInteger pageNum = 30;//默认加载20条
NSString *defaultname = @"烧烤";//默认烧烤

// 刷新加载数据
- (void)setupRefresh{
    
    __weak typeof(self) weakSelf = self;
    // 上拉刷新
    self.collectionView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSLog(@"当前请求的页数：%ld",pageNum);
            pageNum = 40;
            [weakSelf _requestSomeData:40:defaultname:NO];
        });
    }];
    
    // 下拉刷新
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            pageNum+=20;
            [weakSelf _requestSomeData:pageNum:defaultname:NO];
        });
    }];
    
    self.collectionView.mj_footer.hidden = NO;
}

#pragma mark - requestdata请求主页数据
- (void)_requestSomeData:(NSUInteger)page :(NSString *)name :(BOOL)isSerarch{
    
    loading.hidden = NO;

    [task cancel];
    
    NSString *logInUrl = [NSString stringWithFormat:@"http://apicloud.mob.com/v1/cook/menu/search"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *parameter = @{
                                @"key":@"158556148371e",
                                @"cid":@"",
                                @"name":name,
                                @"page":@"1",
                                @"size":[NSString stringWithFormat:@"%ld",page]
                                       };
    
    task =[manager POST:logInUrl parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            NSError *error = nil;
            
            [weakSelf.searchData removeAllObjects];
            
            if ([[responseObject objectForKey:@"msg"] isEqualToString:@"success"]) {
                
                NSMutableDictionary *responseDic = [responseObject objectForKey:@"result"];
                
                totalCount = [responseDic objectForKey:@"total"];
                
                for (NSDictionary *dic in [responseDic objectForKey:@"list"]) {
                    
                    DishesModel *dishesModel = [[DishesModel alloc] initWithDictionary:dic error:&error];
                    
                   
                    dishesModel.img = [[dic objectForKey:@"recipe"] objectForKey:@"img"]?[[dic objectForKey:@"recipe"] objectForKey:@"img"]:@"http://img3.imgtn.bdimg.com/it/u=3747380359,124260206&fm=26&gp=0.jpg";
                    
                    dishesModel.method = [[dic objectForKey:@"recipe"] objectForKey:@"method"]?[[dic objectForKey:@"recipe"] objectForKey:@"method"]:@"方法丢失😢";
                    
                    dishesModel.ingredients = [[dic objectForKey:@"recipe"] objectForKey:@"ingredients"]?[[dic objectForKey:@"recipe"] objectForKey:@"ingredients"]:@"食材丢失😢";
                    
                    dishesModel.title = [[dic objectForKey:@"recipe"] objectForKey:@"title"]?[[dic objectForKey:@"recipe"] objectForKey:@"title"]:@"...";
                    
                    dishesModel.sumary = [[dic objectForKey:@"recipe"] objectForKey:@"sumary"]?[[dic objectForKey:@"recipe"] objectForKey:@"sumary"]:@"...";
                    
                    [weakSelf.searchData addObject:dishesModel];
                    
                }
            }else if ([[responseObject objectForKey:@"retCode"] isEqualToString:@"20201"]) {
                UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"查询不到数据！" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertVC addAction:confir];
                
                [weakSelf presentViewController:alertVC animated:YES completion:^{
                    
                }];
                
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"查无结果" message:@"是否查看中国菜谱网数据？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                
//                [alertView show];
            }
            [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
        
        if (weakSelf.searchData.count<1) {
            
            [weakSelf showMessage:@"暂无此种美食分类数据"];
        }else {
            [weakSelf showMessage:@"美食加载完成喽 ^o^"];
        }

        loading.hidden = YES;
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer endRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        loading.hidden = YES;
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer endRefreshing];
        
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

//美食分类
- (void)initRightBarItem {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 35)];
    [btn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    btn.showsTouchWhenHighlighted = YES;
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem               = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = addItem;
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 35)];
    [leftBtn setImage:[UIImage imageNamed:@"icon_user"] forState:UIControlStateNormal];
    leftBtn.showsTouchWhenHighlighted = YES;
    [leftBtn addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem               = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)click:(UIButton *)sender {
    
    CGPoint point = CGPointMake(self.view.frame.size.width-10, 64);
    
    if (_popover) {
        [_popover dismiss];
    }
    _titlesArr = @[
                   @"按菜品",@"荤菜",@"素菜",@"汤粥",@"西点",@"主食",@"饮品",@"小吃",
                   @"按工艺",@"红烧",@"炒",@"煎",@"炸",@"焖",@"炖",@"烤",
                   @"按菜系",@"鲁菜",@"川菜",@"粤菜",@"闽菜",@"浙菜",@"湘菜",@"京菜",
                   @"按人群",@"孕妇",@"婴幼",@"儿童",@"懒人",@"宵夜",@"素食",@"茶",
                   @"按功能",@"减肥",@"便秘",@"养胃",@"滋阴",@"补阳",@"月经",@"美容",@"养生",@"贫血",@"润肺"
                   ];
    
    _popover = [JJPopoverView showPopoverAtPoint:point
                                          inView:self.view
                                          titles:_titlesArr
                                        delegate:self];
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {

        self.visualEffectView.alpha = 0;
        DishesWebView *webView = [[DishesWebView alloc] init];
        webView.name = defaultname;
        [self presentViewController:webView animated:YES completion:^{
            
        }];
    }
}
#pragma mark - <JJPopoverViewDelegate>

- (void)popoverView:(JJPopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"点击了:%@", _titlesArr[index]);
    defaultname = _titlesArr[index];
    [self _requestSomeData:20 :defaultname:NO];
    [_popover dismiss];
}

- (void)popoverViewDidDismiss:(JJPopoverView *)popoverView {
}

#pragma mark - <UICollectionViewDataSource>

//  返回头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
//        //添加头视图的内容
        [self initCarouseView];
//        //头视图添加view
//        [header addSubview:_carouselView];
        
        [header addSubview:_cycleScrollView];
        
        return header;
    }
    //如果底部视图
    //    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
    //
    //    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    
    if (self.searchData.count == [totalCount integerValue]) {
        self.collectionView.mj_footer.hidden = YES;
    }else {
        self.collectionView.mj_footer.hidden = NO;
    }
    // 使用searchData显示数据
    return self.searchData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DishCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeCollectionViewCell" owner:self options:nil]lastObject];
        //注册Peek高亮来源***
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    // 使用searchData显示数据
    cell.dishesModel = [_searchData objectAtIndex:indexPath.row];
    
    cell.dishesTitle.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:0.4];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [customSearchBar resignFirstResponder];
    self.menuView.hidden = YES;
    
    DishesDetailVC *detailVC = [[DishesDetailVC alloc] init];
    detailVC.flag = YES;
    detailVC.thumbnail = ((DishesModel *)self.searchData[indexPath.row]).thumbnail;
    detailVC.img = ((DishesModel *)self.searchData[indexPath.row]).img;
    detailVC.titleStr = ((DishesModel *)self.searchData[indexPath.row]).name;
    detailVC.method = ((DishesModel *)self.searchData[indexPath.row]).method;
    detailVC.name = ((DishesModel *)self.searchData[indexPath.row]).title;
    detailVC.ingredients = ((DishesModel *)self.searchData[indexPath.row]).ingredients;
    detailVC.sumary = ((DishesModel *)self.searchData[indexPath.row]).sumary;
    detailVC.menuId = ((DishesModel *)self.searchData[indexPath.row]).menuId;

    [self presentViewController:detailVC animated:YES completion:^{
        
    }];
}


#pragma mark - UISearchBarDelegate

// UISearchBarDelegate定义的方法，用户单击取消按钮时激发该方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [customSearchBar resignFirstResponder];
    
    [UIView animateWithDuration:.3 animations:^{
        self.visualEffectView.alpha = 0;
    }];
    
    customSearchBar.showsCancelButton = NO;
    
    [self.collectionView reloadData];
}

// UISearchBarDelegate定义的方法，当搜索文本框内文本改变时激发该方法
//- (void)searchBar:(UISearchBar *)searchBar
//    textDidChange:(NSString *)searchText
//{
//    NSLog(@"----textDidChange------");
//    // 调用filterBySubstring:方法执行搜索
//    [self filterBySubstring:searchText];
//}

// UISearchBarDelegate定义的方法，用户单击虚拟键盘上Search按键时激发该方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 调用filterBySubstring:方法执行搜索
    [self filterBySubstring:searchBar.text];
    
    
    [UIView animateWithDuration:.5 animations:^{
        
        self.visualEffectView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    searchBar.showsCancelButton = NO;
    // 放弃作为第一个响应者，关闭键盘
    [searchBar resignFirstResponder];
}

- (void) filterBySubstring:(NSString*) subStr
{
    NSLog(@"----filterBySubstring------");
    
//    // 定义搜索谓词
//    NSPredicate* pred = [NSPredicate predicateWithFormat:
//                         @"SELF CONTAINS[c] %@" , subStr];
//    // 使用谓词过滤NSArray
//    searchData = [tableData filteredArrayUsingPredicate:pred];
//    // 让表格控件重新加载数据
//    [tableView reloadData];
    defaultname = subStr;
    [self _requestSomeData:pageNum :subStr:YES];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [customSearchBar resignFirstResponder];
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
    [self.view addSubview:label];
    
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


-(void) playSound

{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"prlm_sound_triggering" ofType:@"wav"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
    }
    
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
}
static HyRoundMenuModel *tempModel = nil;
- (void)roundMenuView:(HyRoundMenuView* __nonnull)roundMenuView dragAfterModel:(HyRoundMenuModel* __nonnull)model
{
    [self playSound];
}

- (void)roundMenuView:(HyRoundMenuView* __nonnull)roundMenuView didSelectRoundMenuModel:(HyRoundMenuModel* __nonnull)model
{

    defaultname = model.title;
    [self _requestSomeData:pageNum :model.title :NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:.5 animations:^{
        
        self.visualEffectView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    customSearchBar.showsCancelButton = NO;
    [customSearchBar resignFirstResponder];
}

#pragma mark - 3d presress isuess

//peek(预览)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
 
    
    /*
     guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
     guard let cell = tableView.cellForRow(at: indexPath) as? DiscoveryComponent else { return nil }
     let collectionView = cell.collectionView
     print("---- CollectionView \(collectionView)----")
     let collectionPoint = collectionView.convert(location, from: tableView)
     guard let collectionIndexPath = collectionView.indexPathForItem(at: collectionPoint) else { return nil }
     guard let collectionViewCell = collectionView.cellForItem(at: collectionIndexPath) as? DiscoveryProductCell else { return nil }
     print(collectionIndexPath)
     */
    
    
    //method 1
//    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(HomeCollectionViewCell *)[previewingContext sourceView]];
    
    
    
    
    //method 2
    // 将collectionView在控制器view的中心点转化成collectionView上的坐标
    CGPoint pInView = [self.view convertPoint:location toView:self.collectionView];
    // 获取这一点的indexPath
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pInView];
    
    
    
//    //method 3
//    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    
    
    //设定预览的界面
    DishesDetailVC *childVC = [[DishesDetailVC alloc] init];
    childVC.preferredContentSize = CGSizeMake(0.0f,500.0f);
    
    [customSearchBar resignFirstResponder];
    
    childVC.flag = YES;
    
    childVC.thumbnail = ((DishesModel *)self.searchData[indexPath.row]).thumbnail;
    childVC.img = ((DishesModel *)self.searchData[indexPath.row]).img;
    childVC.titleStr = ((DishesModel *)self.searchData[indexPath.row]).name;
    childVC.method = ((DishesModel *)self.searchData[indexPath.row]).method;
    childVC.name = ((DishesModel *)self.searchData[indexPath.row]).title;
    childVC.ingredients = ((DishesModel *)self.searchData[indexPath.row]).ingredients;
    childVC.sumary = ((DishesModel *)self.searchData[indexPath.row]).sumary;
    childVC.menuId = ((DishesModel *)self.searchData[indexPath.row]).menuId;
    
    //调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,40);
    previewingContext.sourceRect = rect;
    
    
    //返回预览界面
    return childVC;
}
//pop（按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    //[self.view addSubview: viewControllerToCommit.view];
    //[self showViewController:viewControllerToCommit sender:self];
    [self presentViewController:viewControllerToCommit animated:YES completion:^{
        
    }];
}


#pragma mark - keyboard 键盘弹出视图模糊
- (void)popKeyBoard:(NSNotification *)notification
{
    [UIView animateWithDuration:.3 animations:^{
        self.visualEffectView.alpha = 1;
    }];
    customSearchBar.showsCancelButton = YES;
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
