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

static NSString *const DishCellIdentifier = @"dishesCellIdentifier";

@interface DishesViewController ()
<
JJPopoverViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UISearchBarDelegate
>
{
    NSURLSessionTask *task;
    // 是否搜索变量
    bool isSearch;
    UIImageView *loading;
    UISearchBar *customSearchBar;
    NSString *totalCount;
}

/** 所有的美食数据 */
@property (nonatomic, strong) NSMutableArray *dishes;

@property (nonatomic, weak) JJPopoverView *popover;

@property (nonatomic, strong) NSArray *titlesArr;

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *searchData;// 保存搜索结果数据的NSArray对象。

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation DishesViewController

- (NSMutableArray *)dishes {
    if (!_dishes) {
        _dishes = [NSMutableArray array];
    }
    return _dishes;
}
- (NSMutableArray *)searchData {
    if (!_searchData) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initRightBarItem];
    
    [self setUpLayout];
    
    [self setupRefresh];
    
    // 第一次刷新手动调用
    [self.collectionView.mj_header beginRefreshing];
}

//-(void)setupLeftMenuButton{
//    
//    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
//    [leftDrawerButton setImage:[UIImage imageNamed:@"icon_user"]];
//    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
//}
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
    _flowLayout.itemSize = CGSizeMake(PanScreenWidth/3-PanScreenWidth/17, PanScreenWidth/3);
    
    // 设置最小行间距
    _flowLayout.minimumLineSpacing = 15;
    
    // 设置布局的内边距
    _flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    
    // 滚动方向
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    // 创建CollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) collectionViewLayout:_flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate   = self;
    [self.view addSubview:collectionView];
    
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:DishCellIdentifier];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // 默认没有开始搜索
    isSearch = NO;
    
    CGRect mainViewBounds = self.navigationController.view.bounds;
    customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainViewBounds)/2-((CGRectGetWidth(mainViewBounds)-120)/2), CGRectGetMinY(mainViewBounds)+22, CGRectGetWidth(mainViewBounds)-120, 40)];
    
    customSearchBar.delegate = self;
    customSearchBar.showsCancelButton = NO;
    customSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    customSearchBar.placeholder = @"search any dishes";
    
    [self.navigationController.view addSubview: customSearchBar];
    
    //设置刷新view
    loading        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loading.center = self.view.center;
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
            [weakSelf _requestSomeData:20:defaultname:NO];
        });
    }];
    
    // 下拉刷新
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            pageNum+=10;
            [weakSelf _requestSomeData:pageNum:defaultname:NO];
        });
    }];
    
    self.collectionView.mj_footer.hidden = NO;
}

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
            
            if (isSearch) {
                
                [weakSelf.searchData removeAllObjects];
            } else {
                
                [weakSelf.dishes removeAllObjects];
            }
            [weakSelf.dishes removeAllObjects];
            
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
                    
                    if (isSearch) {
                        
                        [weakSelf.searchData addObject:dishesModel];
                    }else {
                        
                        [weakSelf.dishes addObject:dishesModel];
                    }
                }
            }else if ([[responseObject objectForKey:@"retCode"] isEqualToString:@"20201"]) {
                UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"查询不到数据！" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertVC addAction:confir];
                
                [weakSelf presentViewController:alertVC animated:YES completion:^{
                    
                }];
            }
            [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
        [weakSelf showMessage:@"美食加载完成喽 ^o^"];
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
                   @"按菜品",@"荤菜",@"素菜",@"汤粥",@"西点",@"主食",@"饮品",@"更多菜品",
                   @"按工艺",@"红烧",@"炒",@"煎",@"炸",@"焖",@"炖",@"更多工艺",
                   @"按菜系",@"鲁菜",@"川菜",@"粤菜",@"闽菜",@"浙菜",@"湘菜",@"更多菜系",
                   @"按人群",@"孕妇",@"婴幼",@"儿童",@"懒人",@"宵夜",@"素食",@"更多人群",
                   @"按功能",@"减肥",@"便秘",@"养胃",@"滋阴",@"补阳",@"月经",@"美容",@"养生",@"贫血",@"润肺"
                   ];
    
    _popover = [JJPopoverView showPopoverAtPoint:point
                                          inView:self.view
                                          titles:_titlesArr
                                        delegate:self];
    
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
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    
    // 如果处于搜索状态
    if(isSearch){
        
        if (self.searchData.count == [totalCount integerValue]) {
            self.collectionView.mj_footer.hidden = YES;
        }else {
            self.collectionView.mj_footer.hidden = NO;
        }
        // 使用searchData显示数据
        return self.searchData.count;
    }else {
        
        if (self.dishes.count == [totalCount integerValue]) {
            self.collectionView.mj_footer.hidden = YES;
        }else {
            self.collectionView.mj_footer.hidden = NO;
        }
        // 否则使用原始的dishes显示数据
        return self.dishes.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DishCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeCollectionViewCell" owner:self options:nil]lastObject];
    }
    if(isSearch)
    {
        // 使用searchData显示数据
        cell.dishesModel = [_searchData objectAtIndex:indexPath.row];
    }
    else{
        // 否则使用原始的dishes显示数据
        cell.dishesModel = self.dishes[indexPath.item];
    }
    cell.dishesTitle.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:0.4];
    cell.layer.cornerRadius = 5;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [customSearchBar resignFirstResponder];
    
    DishesDetailVC *detailVC = [[DishesDetailVC alloc] init];
    if (isSearch) {
        
        detailVC.thumbnail = ((DishesModel *)self.searchData[indexPath.row]).thumbnail;
        detailVC.img = ((DishesModel *)self.searchData[indexPath.row]).img;
        detailVC.titleStr = ((DishesModel *)self.searchData[indexPath.row]).name;
        detailVC.method = ((DishesModel *)self.searchData[indexPath.row]).method;
        detailVC.name = ((DishesModel *)self.searchData[indexPath.row]).title;
        detailVC.ingredients = ((DishesModel *)self.searchData[indexPath.row]).ingredients;
        detailVC.sumary = ((DishesModel *)self.searchData[indexPath.row]).sumary;
    }else {
        
        detailVC.thumbnail = ((DishesModel *)self.dishes[indexPath.row]).thumbnail;
        detailVC.img = ((DishesModel *)self.dishes[indexPath.row]).img;
        detailVC.titleStr = ((DishesModel *)self.dishes[indexPath.row]).name;
        detailVC.method = ((DishesModel *)self.dishes[indexPath.row]).method;
        detailVC.name = ((DishesModel *)self.dishes[indexPath.row]).title;
        detailVC.ingredients = ((DishesModel *)self.dishes[indexPath.row]).ingredients;
        detailVC.sumary = ((DishesModel *)self.dishes[indexPath.row]).sumary;
    }
    //[self.navigationController showViewController:detailVC sender:nil];
    [self presentViewController:detailVC animated:YES completion:^{
        
    }];
}


#pragma mark - UISearchBarDelegate

// UISearchBarDelegate定义的方法，用户单击取消按钮时激发该方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"----searchBarCancelButtonClicked------");
    // 取消搜索状态
    isSearch = NO;
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
    NSLog(@"----searchBarSearchButtonClicked------");
    // 调用filterBySubstring:方法执行搜索
    [self filterBySubstring:searchBar.text];
    // 放弃作为第一个响应者，关闭键盘
    [searchBar resignFirstResponder];
}

- (void) filterBySubstring:(NSString*) subStr
{
    NSLog(@"----filterBySubstring------");
    // 设置为搜索状态
    isSearch = YES;
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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
