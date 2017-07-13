//
//  DishesModel.h
//  Private dishes
//
//  Created by panerly on 10/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import "JSONModel.h"

@interface DishesModel : JSONModel

@property (nonatomic, strong) NSString<Optional> *thumbnail;      //缩略图
@property (nonatomic, strong) NSString *name;                     //菜名
@property (nonatomic, strong) NSString<Optional> *ctglds;         //类目
@property (nonatomic, strong) NSString<Optional> *cgtTitles;      //所属类别


//@property (nonatomic, strong) NSMutableArray *recipe;
@property (nonatomic, strong) NSString<Optional> *img;            //大图
@property (nonatomic, strong) NSString<Optional> *title;          //此道菜的做法的名称
@property (nonatomic, strong) NSString<Optional> *sumary;         //点评总结
@property (nonatomic, strong) NSString<Optional> *ingredients;    //材料
@property (nonatomic, strong) NSString<Optional> *method;         //方法
@property (nonatomic, strong) NSString<Optional> *menuId;         //方法

@end
