//
//  LeftViewModel.h
//  Private dishes
//
//  Created by panerly on 12/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import "JSONModel.h"

@interface LeftViewModel : JSONModel

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *menuId;

@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic, strong) UIImage *thumbnail;

@end
