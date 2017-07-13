//
//  HomeCollectionViewCell.h
//  Private dishes
//
//  Created by panerly on 10/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DishesModel.h"

@interface HomeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dishesTitle;
@property (weak, nonatomic) IBOutlet UIImageView *dishesImg;
@property (weak, nonatomic) IBOutlet UIImageView *shadowView;

@property (nonatomic, strong) DishesModel *dishesModel;

@end
