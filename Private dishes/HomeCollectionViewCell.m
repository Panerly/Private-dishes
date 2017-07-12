//
//  HomeCollectionViewCell.m
//  Private dishes
//
//  Created by panerly on 10/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation HomeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}


- (void)setDishesModel:(DishesModel *)dishesModel {
    
    //1.图片
    [self.dishesImg sd_setImageWithURL:[NSURL URLWithString:dishesModel.thumbnail] placeholderImage:[UIImage imageNamed:@"lost2"]];
    //2.菜名
    self.dishesTitle.text = dishesModel.name;
}
@end
