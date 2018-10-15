//
//  CZArrowMenuTableViewCell.h
//  CZArrowMenu
//
//  Created by siu on 2018/10/13.
//

#import <UIKit/UIKit.h>
#import "CZArrowMenuItem.h"


NS_ASSUME_NONNULL_BEGIN

@protocol CZArrowMenuCellDelegate;

@interface CZArrowMenuTableViewCell : UITableViewCell
@property (nonatomic, strong) CZArrowMenuItem *item;
@property (nonatomic, weak) UIButton *button;
@property (nonatomic, weak) id <CZArrowMenuCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
