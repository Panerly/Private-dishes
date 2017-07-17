//
//  UserInfoViewController.m
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserNameViewController.h"
#import "TZPopInputView.h"

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSString *cellID;
    NSData *imageData;
    NSUserDefaults *defaults;
    UIDatePicker *datePicker;
    NSUInteger fileSize;
}
@property (nonatomic, strong) TZPopInputView *inputView;    // 输入框

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"账户信息";
    self.view.backgroundColor = COLORRGB(238, 238, 238);
    
    self.userIcon.clipsToBounds = YES;
    self.userIcon.layer.cornerRadius = 50;
    [self.userIcon.layer setMasksToBounds:YES];
    [self.userIcon.layer setBorderColor:COLORRGB(233, 233, 216).CGColor];
    [self.userIcon.layer setBorderWidth:2];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    [self _setTableView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[UIStoryboard storyboardWithName:@"userInfor" bundle:nil] instantiateViewControllerWithIdentifier:@"userInforID"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"image"];
    if (imageData != nil) {
        [_userIcon setImage:[NSKeyedUnarchiver unarchiveObjectWithData:imageData] forState:UIControlStateNormal];
    }
    _userIcon.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration:0.5 animations:^{
        _userIcon.transform = CGAffineTransformIdentity;
    }];
    
    if ([defaults objectForKey:@"userNameValue"] != nil) {
        _userNameLabel.text = [defaults objectForKey:@"userNameValue"];
    }
    fileSize = [[SDImageCache sharedImageCache] getDiskCount];
}

//设置输入框并赋值上次预设值
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_inputView) {
        self.inputView = [[TZPopInputView alloc] init];
    }
    if (![defaults objectForKey:@"litMeterAlarmValue"]) {
        _inputView.textFiled1.text = [defaults objectForKey:@"litMeterAlarmValue"];
    }
    if (![defaults objectForKey:@"bigMeterAlarmValue"]) {
        _inputView.textFiled2.text = [defaults objectForKey:@"bigMeterAlarmValue"];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.5 animations:^{
        _userIcon.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }];
}

- (void)_setTableView
{
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.cornerRadius = 5;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    cellID = @"attrIdenty";
}

//点击更换头像
- (IBAction)userImage:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *change = [UIAlertAction actionWithTitle:@"修改头像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [weakSelf presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:change];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"修改昵称";
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"清理内存";
    }
    if (indexPath.row == 2) {
        
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"sex"] isEqualToString:@"男"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"sex"] isEqualToString:@"女"]) {
            cell.textLabel.text = @"性别 : 男";
        }else {
            
            cell.textLabel.text = [NSString stringWithFormat:@"性别 ：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"sex"]];
        }
    }
    if (indexPath.row == 3) {
        cell.textLabel.text = @"关于";
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        UserNameViewController *userNameVC = [[UserNameViewController alloc] init];
        [self showViewController:userNameVC sender:nil];
    }
    if (indexPath.row == 1){
        
        if (fileSize/1024.0/1024.0 > 0) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否清理缓存？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [[SDImageCache sharedImageCache] cleanDisk];
                
                fileSize = [[SDImageCache sharedImageCache] getDiskCount];
                
                [self.tableView reloadData];
                
                [SCToastView showInView:self.view text:@"已清理" duration:.5f autoHide:YES];
            }];
            
            [alert addAction:cancel];
            [alert addAction:confirm];
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        } else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂无缓存可清除！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        }
        
        
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    }
    if (indexPath.row == 2) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *boy = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [defaults setObject:@"男" forKey:@"sex"];
            [defaults synchronize];
            [_tableView reloadData];
        }];
        UIAlertAction *girl = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [defaults setObject:@"女" forKey:@"sex"];
            [defaults synchronize];
            [_tableView reloadData];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:boy];
        [alert addAction:girl];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    if (indexPath.row == 3) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *boy = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [defaults setObject:@"男" forKey:@"sex"];
            [defaults synchronize];
            [_tableView reloadData];
        }];
        UIAlertAction *girl = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [defaults setObject:@"女" forKey:@"sex"];
            [defaults synchronize];
            [_tableView reloadData];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:boy];
        [alert addAction:girl];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    
    [_userIcon setImage:image forState:UIControlStateNormal];

    imageData = [NSKeyedArchiver archivedDataWithRootObject:image];
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"image"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

- (void)setDatePicker
{
    NSString *bornDate;
    if (!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, PanScreenHeight-100-49, PanScreenWidth, 100)];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.backgroundColor = [UIColor lightGrayColor];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, PanScreenHeight-100, PanScreenWidth, 30)];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [datePicker addSubview:btn];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy年MM月dd日";
        bornDate = [formatter stringFromDate:[defaults objectForKey:@"bornStr"]];
    }
    [self.view addSubview:datePicker];
    
    [defaults setObject:bornDate forKey:@"bornDate"];
    [defaults synchronize];
    [_tableView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:.5 animations:^{
        datePicker.frame = CGRectMake(0, PanScreenHeight, PanScreenWidth, 100);
    } completion:^(BOOL finished) {
        [datePicker removeFromSuperview];
    }];
}

@end
