//
//  TitleView.h
//
//  Created by mac on 16/2/5.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIButton *leftBarButton;
@property (nonatomic, strong) UIButton *rightBarButton;
@property (nonatomic, assign) BOOL isTranslucent;
@property (nonatomic, assign) BOOL isLeftBtnRotation;
@end
