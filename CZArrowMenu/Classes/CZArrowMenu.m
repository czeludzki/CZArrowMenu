//
//  CZArrowMenu.m
//  IAskDoctorNew
//
//  Created by siu on 10/10/2018.
//  Copyright © 2018年 IAsk. All rights reserved.
//

#import "CZArrowMenu.h"
#import "CZArrowMenuCollectionViewCell.h"
#import <Masonry/Masonry.h>

#define k_appKeyWindow [UIApplication sharedApplication].keyWindow
#define k_cornerRadius 8.0

#define k_collectionViewHeight 44.0
#define k_collectionViewMargin 8.0

#define k_arrowHeight 8

// 等边三角形 高度(0.86625) : 边长(1)
#define k_triangleRatio 0.86625

@interface CZArrowMenu () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) CZArrowMenuDirection direction;
@property (nonatomic, assign) CZArrowMenuPointingPosition pointingPosition;
@property (nonatomic, strong) NSArray <CZArrowMenuItem *>*items;

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;


/**
 为了实现小尖角效果, 为 self.effectView.layer 添加一个 maskLayer
 */
@property (nonatomic, strong) CAShapeLayer *maskLayer;
/**
 在给 tableView 或 collectionView 设置 autoLayout 定位时, 需要根据 self.pointingPosition 给四周预留空间放置 箭头
 */
@property (nonatomic, assign) UIEdgeInsets contentEdges;
@end

@implementation CZArrowMenu

#pragma mark - Getter && Setter
- (CAShapeLayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [[CAShapeLayer alloc] init];
        _maskLayer.lineJoin = kCALineJoinRound;
        _maskLayer.lineCap = kCALineCapRound;
        
        [self layoutIfNeeded];
        [self updateConstraintsIfNeeded];
        CGSize contentSize = self.effectView.frame.size;
        // 已知 等边三角形高度, 求等边三角形的边长
        CGFloat lengthOfSide = k_arrowHeight / k_triangleRatio;
        
        UIBezierPath *b_path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, k_arrowHeight, contentSize.width, contentSize.height - k_arrowHeight) cornerRadius:k_cornerRadius];
        // 利用 CAShapeLayer 画尖角
        [b_path moveToPoint:CGPointMake(20, k_arrowHeight)];
        [b_path addLineToPoint:CGPointMake((lengthOfSide / 2) + 20, 0)];
        [b_path addLineToPoint:CGPointMake(lengthOfSide + 20, k_arrowHeight)];
        [b_path closePath];
        
        _maskLayer.path = b_path.CGPath;
    }
    return _maskLayer;
}

- (UIVisualEffectView *)effectView
{
    if (!_effectView) {
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIEdgeInsets)contentEdges
{
    NSValue *top = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(k_arrowHeight, 0, 0, 0)];
    NSValue *left = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, k_arrowHeight, 0, 0)];
    NSValue *bottom = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 0, k_arrowHeight, 0)];
    NSValue *right = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 0, 0, k_arrowHeight)];
    NSArray <NSValue *>*t_arr = @[top, left, bottom, right];
    return t_arr[self.pointingPosition].UIEdgeInsetsValue;
}

static NSString *CZArrowMenuCollectionViewCellID = @"CZArrowMenuCollectionViewCellID";
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[CZArrowMenuCollectionViewCell class] forCellWithReuseIdentifier:CZArrowMenuCollectionViewCellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

#pragma mark - life cycle
- (instancetype)initWithDirection:(CZArrowMenuDirection)direction Items:(NSArray <CZArrowMenuItem *>*)items
{
    if (self = [super init]) {
        self.items = items;
        self.direction = direction;
        self.edgeInsetsFromWindow = UIEdgeInsetsMake(15, 15, 15, 15);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
        NSAssert((self.direction == CZArrowMenuDirection_Horizontal || self.direction == CZArrowMenuDirection_Vertical), @"direction 值有误");
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:self.effectView];
        
        if (direction == CZArrowMenuDirection_Horizontal) {
            [self.effectView.contentView addSubview:self.collectionView];
        }
        
        if (direction == CZArrowMenuDirection_Vertical) {
            [self.effectView.contentView addSubview:self.tableView];
        }
    }
    return self;
}

#pragma mark - Action
- (void)tapOnView:(UITapGestureRecognizer *)sender
{
    [self removeFromSuperview];
}

#pragma mark - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CZArrowMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CZArrowMenuCollectionViewCellID forIndexPath:indexPath];
    cell.item = self.items[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CZArrowMenuItem *item = self.items[indexPath.item];
    UIButton *t_b = [UIButton buttonWithType:UIButtonTypeSystem];
    t_b.titleLabel.font = item.font;
    [t_b setTitle:item.title forState:UIControlStateNormal];
    [t_b setImage:item.img forState:UIControlStateNormal];
    [t_b sizeToFit];
    return CGSizeMake(t_b.frame.size.width, k_collectionViewHeight - k_collectionViewMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return k_collectionViewMargin * 2;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(k_collectionViewMargin * .5f, k_collectionViewMargin, k_collectionViewMargin * .5f, k_collectionViewMargin);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Helper
- (void)showWithArrowTarget:(UIView *)arrowTarget pointingPosition:(CZArrowMenuPointingPosition)pointingPosition
{
    self.pointingPosition = pointingPosition;
    
    __block UIColor *t_color = self.backgroundColor;
    __weak __typeof (self) weakSelf = self;
    
    [k_appKeyWindow addSubview:self];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self confirmContentRect:arrowTarget];
    
    [UIView animateWithDuration:.3f animations:^{
        weakSelf.backgroundColor = t_color;
    }];
}

/**
 布置 effectView 的定位
 */
- (void)confirmContentRect:(UIView *)arrowTarget
{
    __weak __typeof (self) weakSelf = self;
    
    // 先设置当前 mainContentView 的 autoLayout
    [[self mainContentView] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.contentEdges);
    }];
    
    // 先给 effectView 设置 rect, 以便计算 tableview 或 collectionView 的 contentsize, 以下mas_makeConstraints中设置的都是临时的值
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(k_collectionViewHeight + k_arrowHeight);
    }];
    [self.effectView layoutIfNeeded];
    
    // 获得 tableview 或 collectionView 的 contentsize
    CGSize effectViewSize = [self effectViewSize];
    [self.effectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(effectViewSize.width);
        make.height.mas_equalTo(effectViewSize.height);
    }];
    
    CGPoint effectViewPosition = [self effectViewPositionWithTarget:arrowTarget pointingPosition:self.pointingPosition effectViewSize:effectViewSize];
    [self.effectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(effectViewPosition.x);
        make.top.mas_equalTo(effectViewPosition.y);
    }];

    self.effectView.layer.mask = self.maskLayer;
}

/**
 计算(决定) effectView 的大小
 遵循以下原则:
 1. 宽 不能超出 屏幕宽 - (self.edgeInsetsFromWindow.left + self.edgeInsetsFromWindow.right) 这个量
 2. 高 不能超出 屏幕高 - (self.edgeInsetsFromWindow.top + self.edgeInsetsFromWindow.bottom) 这个量
 3. 如果 self.direction == CZArrowMenuDirection_Horizontal, mainContentView 是 collectionView 时, 高度限制为 k_collectionViewHeight + k_arrowHeight
 */
- (CGSize)effectViewSize
{
    CGSize contentSize = [self mainContentView].contentSize;
    CGFloat w = contentSize.width;
    CGFloat h = contentSize.height;
    if (w > k_appKeyWindow.frame.size.width) {
        w = k_appKeyWindow.frame.size.width - (self.edgeInsetsFromWindow.left + self.edgeInsetsFromWindow.right);
    }
    if (h > k_appKeyWindow.frame.size.height) {
        h = k_appKeyWindow.frame.size.height - (self.edgeInsetsFromWindow.top + self.edgeInsetsFromWindow.bottom);
    }
    // 如果 mainContentView 是 collectionView, effectView 的高度为 k_collectionViewHeight + k_arrowHeight
    if (self.direction == CZArrowMenuDirection_Horizontal) {
        h = k_collectionViewHeight + k_arrowHeight;
    }
    return CGSizeMake(w, h);
}

/**
 通过 target(被指向的目标) 以及 pointingPosition(指向的位置), 计算(决定) contentView 的布局位置
 遵守以下原则
 1. effectView 优先与 targetView 保持居中
 2. 如果 当 effectView 与 targetView 居中, 会超出屏幕, 则使 effectView 左移,右移,上移,下移, 偏移规则见下面 2.1
    2.1. 以 pointingPosition == CZArrowMenuPointingPosition_Top 以及 pointingPosition == CZArrowMenuPointingPosition_Bottom 为例, 当 effectView 因为定位位置超出屏幕, 则左移或右移, 如果 targetView.centerX > keyWindow.width / 2, 则使 effectView 左移, 否则右移
    2.2. 以 pointingPosition == CZArrowMenuPointingPosition_Left 以及 pointingPosition == CZArrowMenuPointingPosition_Right 为例, 当 effectView 因为定位位置超出屏幕, 则上移或下移, 如果 targetView.centerY > keyWindow.height / 2, 则使 effectView 上移, 否则下移
 3. 无论怎么偏移, 距离屏幕边缘不能超出 self.edgeInsetsFromWindow
 4. 当因为 pointingPosition 设置不正确导致的无法通过 偏移处理来使 effectView 正确显示, 则不作处理
 */
- (CGPoint)effectViewPositionWithTarget:(UIView *)target pointingPosition:(CZArrowMenuPointingPosition)pointingPosition effectViewSize:(CGSize)effectViewSize
{
    CGPoint t_p = CGPointZero;
    CGRect targetRectInWindow = [target convertRect:target.bounds toView:k_appKeyWindow];
    if (pointingPosition == CZArrowMenuPointingPosition_Top) {
        t_p = CGPointMake(CGRectGetMidX(targetRectInWindow), CGRectGetMinY(targetRectInWindow));
    }
    if (pointingPosition == CZArrowMenuPointingPosition_Left) {
        t_p = CGPointMake(CGRectGetMinX(targetRectInWindow), CGRectGetMidY(targetRectInWindow));
    }
    if (pointingPosition == CZArrowMenuPointingPosition_Bottom) {
        t_p = CGPointMake(CGRectGetMidX(targetRectInWindow), CGRectGetMaxY(targetRectInWindow));
    }
    if (pointingPosition == CZArrowMenuPointingPosition_Right) {
        t_p = CGPointMake(CGRectGetMaxX(targetRectInWindow), CGRectGetMidY(targetRectInWindow));
    }
    return t_p;
}

/**
 通过 self.direction 快速获取到当前使用的 contentView, 可能是 tableview 或 collectionView
 */
- (UIScrollView *)mainContentView
{
    if (self.direction == CZArrowMenuDirection_Vertical) {
        return self.tableView;
    }
    if (self.direction == CZArrowMenuDirection_Horizontal) {
        return self.collectionView;
    }
    return nil;
}

@end
