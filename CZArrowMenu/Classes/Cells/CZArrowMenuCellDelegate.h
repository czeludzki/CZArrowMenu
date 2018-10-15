//
//  CZArrowMenuCellDelegate.h
//  Pods
//
//  Created by siu on 15/10/2018.
//

@class CZArrowMenuItem;
@protocol CZArrowMenuCellDelegate <NSObject>
- (void)arrowMenuCell:(UIView *)cell didSelectedItem:(CZArrowMenuItem *)sender;
@end
