//
//  LeftViewController.m
//  Private dishes
//
//  Created by panerly on 12/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import "LeftViewController.h"
#import "LeftTableViewCell.h"
#import "LeftViewModel.h"
#import "ZCFallLabel.h"
#import <objc/runtime.h>
#import "DishesDetailVC.h"
#import "UserInfoViewController.h"

@interface LeftViewController ()
<
UINavigationControllerDelegate,
UITableViewDelegate,
UITableViewDataSource
>
{
    FMDatabase *db;
    UIImageView *starView;
    ZCAnimatedLabel *label;
    UILabel *tipsLabel;
}
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSMutableArray *labelDataArr;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LeftViewController

- (NSMutableArray *)dataArr {
    
    if (!_dataArr) {
        
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self setupBG];
    
    self.navigationController.delegate = self;
    
    [self initTableView];
    
    label = [[ZCAnimatedLabel alloc] initWithFrame:CGRectMake(55, 90, PanScreenWidth-100-20, 100)];
    
    label.userInteractionEnabled = NO;
    
    [self.view addSubview:label];
    
    [self setupTipsLabel];
    
}

- (void)setupTipsLabel {
    
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, PanScreenWidth/2, PanScreenWidth-100, 100)];
    
    tipsLabel.userInteractionEnabled = NO;
    
    [self.tableView addSubview:tipsLabel];
    
    tipsLabel.font = [UIFont systemFontOfSize:20];
    
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    
    tipsLabel.textColor = [UIColor whiteColor];
    
    tipsLabel.text = @"   No more collected data !";
    
    tipsLabel.hidden = YES;
}

- (void)setupBG{
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PanScreenHeight)];
    
    [bgImageView setImage:[UIImage imageNamed:@"bg_left"]];
    
    [self.view addSubview:bgImageView];
    
    [self setupStarView:bgImageView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 85, PanScreenWidth - 100 - 20, 50)];
    
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
    UIImageView *detailImg =[[UIImageView alloc] initWithFrame:CGRectMake(PanScreenWidth - 100 - 30, 93, 20, 20)];
    [detailImg setImage:[UIImage imageNamed:@"detail"]];
    [self.view addSubview:detailImg];
}

- (void)btnAction {
    
    UserInfoViewController *userInfo = [[UserInfoViewController alloc] init];
    
    [self.navigationController showViewController:userInfo sender:nil];
}

- (void)setupLabel {
    
    
    label.font = [UIFont systemFontOfSize:20];
    
    label.textColor = [UIColor whiteColor];
    label.text = @"This is my dishes";
    label.animationDelay = 0;
    label.animationDuration = 1;
    label.onlyDrawDirtyArea = YES;
    label.layerBased = NO;
    object_setClass(label, [ZCFallLabel class]);
    label.layoutTool.groupType = ZCLayoutGroupChar;
    [label setNeedsDisplay];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 5;
    style.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *mutableString = [[[NSAttributedString alloc] initWithString:label.text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20], NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : [UIColor whiteColor]}] mutableCopy];
    
    
    label.attributedString = mutableString;
}


- (void)setupStarView :(UIImageView *)bgImageView{
    
    starView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25-100/2, 30, 50, 50)];
    starView.image = [UIImage imageNamed:@"icon_star"];
    [bgImageView addSubview:starView];
    
    NSTimer *starTimer = [NSTimer scheduledTimerWithTimeInterval:1.3 target:self selector:@selector(startanmation) userInfo:nil repeats:YES];
    [starTimer fire];
}

- (void)startanmation{
    
    [self animationWithView:starView duration:.5];
}

//缩放动画
- (void)animationWithView:(UIImageView *)view duration:(CFTimeInterval)duration{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];

    [view.layer addAnimation:animation forKey:nil];
}

//视图进入刷新数据
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self queryDB];
    
    
    
    [self setupLabel];
    label.hidden = NO;
    [label startAppearAnimation];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    label.hidden = YES;
}

- (void)queryDB {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"dishes.sqlite"];
    
    db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *resultSet = [db executeQuery:@"select * from dishesTable order by id"];
        
        [self.dataArr removeAllObjects];
        
        while ([resultSet next]) {
            
            NSString *nameString  = [resultSet stringForColumn:@"name"];
            NSString *menuIDString = [resultSet stringForColumn:@"menuId"];
            NSString *titleString = [resultSet stringForColumn:@"titleStr"];
            NSData *img = [resultSet dataForColumn:@"img"];
            
            LeftViewModel *dbModel    = [[LeftViewModel alloc] init];
            dbModel.title    = [NSString stringWithFormat:@"%@",nameString];
            dbModel.menuId = menuIDString;
            dbModel.titleStr = titleString;
            
            if (nameString) {
                
                dbModel.thumbnail  = [UIImage imageWithData:img];
            }else {
                
                dbModel.thumbnail = [UIImage imageNamed:@"lost2"];
            }
            
            [self.dataArr addObject:dbModel];
            
        }
        if (self.dataArr.count == 0) {
            
            tipsLabel.hidden = NO;
            
        }else{
            
            tipsLabel.hidden = YES;
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
        [db close];
    }
}

- (void)initTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width-100, PanScreenHeight - 150) style:UITableViewStylePlain];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
}


#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LeftTableViewCell" owner:self options:nil] lastObject];
    }
    cell.leftModel          = self.dataArr[indexPath.row];
    cell.backgroundColor    = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DishesDetailVC *detail = [[DishesDetailVC alloc] init];
    detail.flag = NO;
    detail.menuId = ((LeftViewModel *)self.dataArr[indexPath.row]).menuId;
    detail.titleStr = ((LeftViewModel *)self.dataArr[indexPath.row]).titleStr;
    
    [self presentViewController:detail animated:YES completion:^{
        
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //从数据库中删除
    
    NSString *nameString = ((LeftViewModel *)self.dataArr[indexPath.row]).title;
    NSLog(@"要删除的name：%@",nameString);
    
    if ([db open]) {
        
        [db executeUpdate:[NSString stringWithFormat:@"delete from dishesTable where name = '%@'",nameString]];
        [db close];
    }
    // 从数据源中删除
    [self.dataArr removeObjectAtIndex:indexPath.row];
    // 从列表中删除
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
