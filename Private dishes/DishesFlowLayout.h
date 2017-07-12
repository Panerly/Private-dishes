//
//  DishesFlowLayout.h
//  Private dishes
//
//  Created by panerly on 10/07/2017.
//  Copyright © 2017 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DishesFlowLayout;

@protocol DishesFlowLayoutDelegate <NSObject>
@required
- (CGFloat)waterflowLayout:(DishesFlowLayout *)waterflowLayout heightForItemAtIndex:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;

@optional
- (CGFloat)columnCountInWaterflowLayout:(DishesFlowLayout *)waterflowLayout;
- (CGFloat)columnMarginInWaterflowLayout:(DishesFlowLayout *)waterflowLayout;
- (CGFloat)rowMarginInWaterflowLayout:(DishesFlowLayout *)waterflowLayout;
- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(DishesFlowLayout *)waterflowLayout;

@end

@interface DishesFlowLayout : UICollectionViewFlowLayout

/** 代理 */
@property (nonatomic, weak) id<DishesFlowLayoutDelegate> delegate;

@end
