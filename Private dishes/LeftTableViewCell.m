//
//  LeftTableViewCell.m
//  Private dishes
//
//  Created by panerly on 12/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import "LeftTableViewCell.h"

@implementation LeftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLeftModel:(LeftViewModel *)leftModel {
    
    //1.图片
    if (!leftModel.thumbnail) {
        
        self.shadowView.hidden = YES;
    }
    [self.imgView setImage:leftModel.thumbnail?leftModel.thumbnail:[UIImage imageNamed:@"losts"]];

    
    //2.菜名
    self.title.text = leftModel.title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
