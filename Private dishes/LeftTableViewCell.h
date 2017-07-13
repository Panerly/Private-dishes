//
//  LeftTableViewCell.h
//  Private dishes
//
//  Created by panerly on 12/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftViewModel.h"

@interface LeftTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (nonatomic, strong) LeftViewModel *leftModel;

@end
