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

@interface CZArrowMenu : UIView
@property (assign, nonatomic) UIEdgeInsets edgeInsetsFromWindow;

- (instancetype)initWithDirection:(CZArrowMenuDirection)direction Items:(NSArray <CZArrowMenuItem *>*)items;
- (void)showWithArrowTarget:(UIView *)arrowTarget pointingPosition:(CZArrowMenuPointingPosition)pointingPosition;
@end

NS_ASSUME_NONNULL_END
