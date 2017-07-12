//
//  DishesDetailVC.h
//  Private dishes
//
//  Created by panerly on 10/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DishesDetailVC : UIViewController

@property (nonatomic, strong) TitleView *titleView;


@property (nonatomic, copy) NSString *thumbnail;      //缩略图
@property (nonatomic, copy) NSString *img;            //大图
@property (nonatomic, copy) NSString *name;           //菜名
@property (nonatomic, copy) NSString *ctglds;         //类目
@property (nonatomic, copy) NSString *cgtTitles;      //所属类别
@property (nonatomic, copy) NSString *method;         //方法
@property (nonatomic, copy) NSString *titleStr;       //此道菜的做法的名称
@property (nonatomic, copy) NSString *ingredients;    //材料
@property (nonatomic, copy) NSString *sumary;         //点评总结

@end
