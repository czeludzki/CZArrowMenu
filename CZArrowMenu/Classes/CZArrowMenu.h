//
//  CZArrowMenu.h
//  IAskDoctorNew
//
//  Created by siu on 10/10/2018.
//  Copyright © 2018年 IAsk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZArrowMenuItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CZArrowMenuDirection) {
    CZArrowMenuDirection_Vertical = 0,  // 垂直 (使用的tableView)
    CZArrowMenuDirection_Horizontal = 1     // 水平(使用的collectionView)
};

/**
 表示菜单箭头该指向目标按钮的 上左下右 四个方位
 例如点击 按钮A, 将弹出带有箭头指向 按钮A 的菜单, 箭头该指向 按钮A 的哪个位置, 也决定了菜单的展示方向
 */
typedef NS_ENUM(NSUInteger, CZArrowMenuPointingPosition) {
    CZArrowMenuPointingPosition_Top = 0,
    CZArrowMenuPointingPosition_Left = 1,
    CZArrowMenuPointingPosition_Bottom = 2,
    CZArrowMenuPointingPosition_Right = 3
};

@class CZArrowMenu;
@protocol CZArrowMenuDelegate <NSObject>
- (void)arrowMenu:(CZArrowMenu *)menu didSelectedItem:(CZArrowMenuItem *)item atIndex:(NSInteger)index;
@end

@interface CZArrowMenu : UIView
@property (nonatomic, weak) id <CZArrowMenuDelegate>delegate;
/**
 当 系统版本 > ios11 时, 以 .top 为例, edgeInsetsFromWindow = edgeInsetsFromWindow.top + keyWindow.safeAreaInsets.top
 */
@property (assign, nonatomic) UIEdgeInsets edgeInsetsFromWindow;
/**
 当样式为 CZArrowMenuDirection_Vertical 时, 就是tableView每一行内容的高度,
 当样式为 CZArrowMenuDirection_Horizontal 时, 就是collectionView的高度.
 default is 44
 */
@property (assign, nonatomic) CGFloat contentHeight;
/**
 当样式为 CZArrowMenuDirection_Vertical 时, 就是tableView的宽度, default is 128
 */
@property (assign, nonatomic) CGFloat contentWidth;
/**
 当样式为 CZArrowMenuDirection_Vertical 时, 就是tableViewCell每一行内容的对齐方式
 */
@property (assign, nonatomic) UIControlContentHorizontalAlignment contentHorizontalAlignment;
/**
 default is YES
 */
@property (assign, nonatomic) BOOL autoDismissWhenItemSelected;
/**
 内容视图的效果
 */
@property (assign, nonatomic) UIBlurEffectStyle effectStyle;
/**
 批量决定 items<CZArrowMenu> 的 selectedColor 属性, 以最后设置的为准
 */
@property (strong, nonatomic) UIColor *selectedColor;
/**
 批量决定 items<CZArrowMenu> 的 tintColor 属性, 以最后设置的为准
 */
@property (strong, nonatomic) UIColor *tintColor;
/**
 批量决定 items<CZArrowMenu> 的 font 属性, 以最后设置的为准
 */
@property (strong, nonatomic) UIFont *font;

- (instancetype)initWithDirection:(CZArrowMenuDirection)direction items:(NSArray <CZArrowMenuItem *>*)items;
- (void)showWithArrowTarget:(UIView *)arrowTarget pointingPosition:(CZArrowMenuPointingPosition)pointingPosition;
- (void)dismiss;
/**
 只是重新赋值 cell.item
 */
- (void)reloadItems;
/**
 调用 tableView || collectionView reloadData
 */
- (void)reload;
@end

NS_ASSUME_NONNULL_END
