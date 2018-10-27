//
//  CZArrowMenu.m
//  IAskDoctorNew
//
//  Created by siu on 10/10/2018.
//  Copyright © 2018年 IAsk. All rights reserved.
//

#import "CZArrowMenu.h"
#import "CZArrowMenuTableViewCell.h"
#import "CZArrowMenuCollectionViewCell.h"
#import "Masonry.h"
#import "CZArrowMenuCellDelegate.h"

#define k_appKeyWindow [UIApplication sharedApplication].keyWindow
// 圆角度数
#define k_cornerRadius 8.0
// collectionview item size 默认宽高, 以及 tableView cell 默认高度
#define k_defaultWH 44.0
// tableView 的默认宽度
#define k_defaultTableViewWidth 128
// collectionviewCell 间距
#define k_collectionViewMargin 8.0
// 箭头高度
#define k_arrowHeight 8
// 等边三角形 高度(0.86625) : 边长(1)
#define k_triangleRatio 0.86625

/**
 用这个结构体来表示 计算好后的 self.effectView 位置
 pointingPosition: 箭头的指向
 offset: 偏移量 (top: 10, left:10)
 center: 在autolayout中, 以center来设置 self.effectView 的 center
 */
typedef struct CZArrowCenterPosition {
    CZArrowMenuPointingPosition pointingPosition;
    UIEdgeInsets offset;
    CGPoint center;
} CZArrowCenterPosition;

UIKIT_STATIC_INLINE struct CZArrowCenterPosition CZArrowCenterPositionMake(CZArrowMenuPointingPosition pointingPostion, CGFloat offset_top, CGFloat offset_left, CGFloat offset_bottom, CGFloat offset_right, CGFloat centerX, CGFloat centerY)
{
    struct CZArrowCenterPosition p;
    p.pointingPosition = pointingPostion;
    p.offset = UIEdgeInsetsMake(offset_top, offset_left, offset_bottom, offset_right);
    p.center = CGPointMake(centerX, centerY);
    return p;
}

/**
 在判断方法 -(BOOL)judgeEffectViewIsBeyondScreenWithEffectViewCenter:effectViewSize 中, 返回这一结构体以表示 effectView 是否超出了屏幕
 当设置适当的 offset 可使 effectView 不超出屏幕, 则 isBeyond 为 NO,
 当设置了适当的 offset, 还是无法使 effectView 不超出屏幕, 则 isBeyond 为 YES
 */
typedef struct CZArrowMenuBeyondScreenJudgeResult{
    // 超出了屏幕
    BOOL isBeyond;
    // 设置偏移量可使 self.effectView 不超出屏幕
    UIEdgeInsets offset;
    // 如果因为 宽高 因素超出了屏幕, 调整新的宽高
    CGSize size;
    // 因为有可能调整宽高, 所以定位也要根据需要调整
    UIEdgeInsets sizeOffset;
}CZArrowMenuBeyondScreenJudgeResult;

typedef struct EffectViewRectInfo{
    CZArrowCenterPosition position;
    CGSize size;
} EffectViewRectInfo;

// 需要偏移的方向
typedef NS_ENUM(NSUInteger, OffsetDirection) {
    OffsetDirection_top = 0,
    OffsetDirection_left = 1,
    OffsetDirection_bottom = 2,
    OffsetDirection_right = 3,
};

@interface CZArrowMenu () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, CZArrowMenuCellDelegate>
@property (nonatomic, assign) CZArrowMenuDirection direction;
@property (nonatomic, assign) CZArrowMenuPointingPosition pointingPosition;
@property (nonatomic, strong) NSArray <CZArrowMenuItem *>*items;

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
/**
 在给 tableView 或 collectionView 设置 autoLayout 定位时, 需要根据 self.pointingPosition 给四周预留空间放置 箭头
 */
@property (readonly) UIEdgeInsets contentEdges;
@property (readonly) CGAffineTransform effectViewTransform;
@property (nonatomic, assign) EffectViewRectInfo effectViewRectInfo;
@property (nonatomic, weak) UIView *targetView;
@end

@implementation CZArrowMenu

#pragma mark - Getter && Setter
- (UIVisualEffectView *)effectView
{
    if (!_effectView) {
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectView;
}

static NSString *CZArrowMenuTableViewCellID = @"CZArrowMenuTableViewCellID";
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[CZArrowMenuTableViewCell class] forCellReuseIdentifier:CZArrowMenuTableViewCellID];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor lightGrayColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

static NSString *CZArrowMenuCollectionViewCellID = @"CZArrowMenuCollectionViewCellID";
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[CZArrowMenuCollectionViewCell class] forCellWithReuseIdentifier:CZArrowMenuCollectionViewCellID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (UIEdgeInsets)contentEdges
{
    NSValue *top = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 0, k_arrowHeight, 0)];
    NSValue *left = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 0, 0, k_arrowHeight)];
    NSValue *bottom = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(k_arrowHeight, 0, 0, 0)];
    NSValue *right = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, k_arrowHeight, 0, 0)];
    NSArray <NSValue *>*t_arr = @[top, left, bottom, right];
    return t_arr[self.pointingPosition].UIEdgeInsetsValue;
}

- (CGAffineTransform)effectViewTransform
{
    NSValue *transform_top = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(self.effectViewRectInfo.position.offset.left + self.effectViewRectInfo.position.offset.right, self.effectView.bounds.size.height * .5f)];
    NSValue *transform_left = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(self.effectView.bounds.size.width * .5f, self.effectViewRectInfo.position.offset.top + self.effectViewRectInfo.position.offset.bottom)];
    NSValue *transform_bottom = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(self.effectViewRectInfo.position.offset.left + self.effectViewRectInfo.position.offset.right, -self.effectView.bounds.size.height / 2)];
    NSValue *transform_right = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(-self.effectView.bounds.size.width * .5f, self.effectViewRectInfo.position.offset.top + self.effectViewRectInfo.position.offset.bottom)];
    NSArray <NSValue *>*t_arr = @[transform_top, transform_left, transform_bottom, transform_right];
    return t_arr[self.pointingPosition].CGAffineTransformValue;
}

- (void)setEdgeInsetsFromWindow:(UIEdgeInsets)edgeInsetsFromWindow
{
    _edgeInsetsFromWindow = edgeInsetsFromWindow;
    if (@available(iOS 11.0, *)) {
        _edgeInsetsFromWindow.top += k_appKeyWindow.safeAreaInsets.top;
        _edgeInsetsFromWindow.left += k_appKeyWindow.safeAreaInsets.left;
        _edgeInsetsFromWindow.bottom += k_appKeyWindow.safeAreaInsets.bottom;
        _edgeInsetsFromWindow.right += k_appKeyWindow.safeAreaInsets.right;
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    [self.items makeObjectsPerformSelector:@selector(setSelectedColor:) withObject:_selectedColor];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self.items makeObjectsPerformSelector:@selector(setTintColor:) withObject:tintColor];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self.items makeObjectsPerformSelector:@selector(setFont:) withObject:_font];
}

- (void)setEffectStyle:(UIBlurEffectStyle)effectStyle
{
    _effectStyle = effectStyle;
    self.effectView.effect = [UIBlurEffect effectWithStyle:_effectStyle];
}

#pragma mark - life cycle
- (instancetype)initWithDirection:(CZArrowMenuDirection)direction items:(NSArray <CZArrowMenuItem *>*)items
{
    if (self = [super init]) {
        _items = items;
        _direction = direction;
        _autoDismissWhenItemSelected = YES;
        _contentHeight = k_defaultWH;
        _contentWidth = direction == CZArrowMenuDirection_Vertical ? k_defaultTableViewWidth : k_defaultWH;
        _contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        if (@available(iOS 11.0, *)) {
            _edgeInsetsFromWindow = UIEdgeInsetsMake(15 + k_appKeyWindow.safeAreaInsets.top, 15 + k_appKeyWindow.safeAreaInsets.left, 15 + k_appKeyWindow.safeAreaInsets.bottom, 15 + k_appKeyWindow.safeAreaInsets.right);
        } else {
            _edgeInsetsFromWindow = UIEdgeInsetsMake(15, 15, 15, 15);
        }
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
        NSAssert((self.direction == CZArrowMenuDirection_Horizontal || self.direction == CZArrowMenuDirection_Vertical), @"direction 值有误");
                
        [self addSubview:self.effectView];
        
        if (direction == CZArrowMenuDirection_Horizontal) {
            [self.effectView.contentView addSubview:self.collectionView];
        }
        
        if (direction == CZArrowMenuDirection_Vertical) {
            [self.effectView.contentView addSubview:self.tableView];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];    
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
    cell.delegate = self;
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
    return CGSizeMake(t_b.frame.size.width, self.contentHeight - k_collectionViewMargin);
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
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZArrowMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CZArrowMenuTableViewCellID forIndexPath:indexPath];
    cell.item = self.items[indexPath.row];
    if (indexPath.row == self.items.count - 1){
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, tableView.bounds.size.width);
    }else{
        cell.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    cell.button.contentHorizontalAlignment = self.contentHorizontalAlignment;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.contentHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.contentHeight;
}

#pragma mark - CZArrowMenuCellDelegate
- (void)arrowMenuCell:(UIView *)cell didSelectedItem:(CZArrowMenuItem *)item
{
    NSInteger idx = [self.items indexOfObject:item];
    if ([self.delegate respondsToSelector:@selector(arrowMenu:didSelectedItem:atIndex:)]) {
        [self.delegate arrowMenu:self didSelectedItem:item atIndex:idx];
    }
    if (item.handler) {
        item.handler(item, idx);
    }
    [self reloadItems];
    if (self.autoDismissWhenItemSelected) [self dismiss];
}

#pragma mark - Helper
- (void)showWithArrowTarget:(UIView *)arrowTarget pointingPosition:(CZArrowMenuPointingPosition)pointingPosition
{
    NSAssert(arrowTarget, @"arrowTarget 不能为空");
    NSAssert(pointingPosition <= CZArrowMenuPointingPosition_Right, @"pointingPosition 设置错误");
    self.pointingPosition = pointingPosition;
    self.targetView = arrowTarget;
    
    __block UIColor *t_color = self.backgroundColor;
    __weak __typeof (self) weakSelf = self;
    
    [k_appKeyWindow addSubview:self];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self confirmContentRect];
    
    CGAffineTransform transform_s = CGAffineTransformMakeScale(.1f, .1f);
    CGAffineTransform transform_t = self.effectViewTransform;
    self.effectView.transform = CGAffineTransformConcat(transform_s, transform_t);
    self.effectView.alpha = 0;
    [UIView animateWithDuration:.13f delay:0 usingSpringWithDamping:.8f initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.effectView.alpha = 1;
        weakSelf.backgroundColor = t_color;
        weakSelf.effectView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

/**
 布置 effectView 的 position 以及 size
 */
- (void)confirmContentRect
{
    __weak __typeof (self) weakSelf = self;
    
    // 先设置当前 mainContentView 的 autoLayout
    [[self mainContentView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.contentEdges);
    }];
    
    // 先给 effectView 设置 rect, 以便计算 tableview 或 collectionView 的 contentsize, 以下mas_makeConstraints中设置的都是临时的值
    [self.effectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(self.contentHeight + k_arrowHeight);
    }];
    
    [self.effectView layoutIfNeeded];
    
    // 计算出 effectView 的定位 以及 size
    EffectViewRectInfo effectViewRectInfo = [self calculateEffectViewRectInfo];
    
    self.effectViewRectInfo = effectViewRectInfo;
    
    [self.effectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(effectViewRectInfo.size.width);
        make.height.mas_equalTo(effectViewRectInfo.size.height);
        make.centerX.mas_offset(effectViewRectInfo.position.center.x - effectViewRectInfo.position.offset.left - effectViewRectInfo.position.offset.right);
        make.centerY.mas_offset(effectViewRectInfo.position.center.y - effectViewRectInfo.position.offset.top - effectViewRectInfo.position.offset.bottom);
    }];
    
    self.effectView.layer.mask = [self createMaskLayer];
}

/**
 计算(决定) effectView 的 定位 以及 宽高信息
 
 计算(决定) effectView 的宽高
 遵循以下原则:
 1. 宽 不能超出 屏幕宽 - (self.edgeInsetsFromWindow.left + self.edgeInsetsFromWindow.right) 这个量
 2. 高 不能超出 屏幕高 - (self.edgeInsetsFromWindow.top + self.edgeInsetsFromWindow.bottom) 这个量
 3. 如果 self.direction == CZArrowMenuDirection_Horizontal, mainContentView 是 collectionView 时, 高度限制为 k_defaultWH + k_arrowHeight
 
 计算(决定) effectView 的定位
 通过 target(被指向的目标) 以及 pointingPosition(指向的位置), 计算(决定) contentView 的布局位置
 遵守以下原则
 1. effectView 优先与 targetView 保持居中
 2. 如果 当 effectView 与 targetView 居中, 会超出屏幕, 则使 effectView 左移,右移,上移,下移, 偏移规则见下面 2.1
 2.1. 以 pointingPosition == CZArrowMenuPointingPosition_Top 以及 pointingPosition == CZArrowMenuPointingPosition_Bottom 为例, 当 effectView 因为定位位置超出屏幕, 则左移或右移, 如果 targetView.centerX > keyWindow.width / 2, 则使 effectView 左移, 否则右移
 2.2. 以 pointingPosition == CZArrowMenuPointingPosition_Left 以及 pointingPosition == CZArrowMenuPointingPosition_Right 为例, 当 effectView 因为定位位置超出屏幕, 则上移或下移, 如果 targetView.centerY > keyWindow.height / 2, 则使 effectView 上移, 否则下移
 3. 无论怎么偏移, 距离屏幕边缘不能超出 self.edgeInsetsFromWindow
 4. 当因为 pointingPosition 设置不正确导致的无法通过 偏移处理来使 effectView 正确显示, 则不作处理
 */
- (EffectViewRectInfo)calculateEffectViewRectInfo
{
    // 1.先通过 mainContentView.contentSize 大致确认 effectViewSize
    CGSize effectView_size = CGSizeZero;
    CGSize contentSize = [self mainContentView].contentSize;
    CGFloat w = contentSize.width;
    CGFloat h = contentSize.height;
    // 如果 mainContentView 是 collectionView, effectView 的高度为 k_defaultWH + k_arrowHeight
    if (self.direction == CZArrowMenuDirection_Horizontal) {
        if (self.pointingPosition == CZArrowMenuPointingPosition_Bottom || self.pointingPosition == CZArrowMenuPointingPosition_Top) {
            h = self.contentHeight + k_arrowHeight;
        }else{
            h = self.contentHeight;
        }
    }
    if (self.direction == CZArrowMenuDirection_Vertical) {
        if (self.pointingPosition == CZArrowMenuPointingPosition_Left || self.pointingPosition == CZArrowMenuPointingPosition_Right){
            w = self.contentWidth + k_arrowHeight;
        }else{
            w = self.contentWidth;
        }
    }
    if (w > k_appKeyWindow.frame.size.width) {
        w = k_appKeyWindow.frame.size.width - (self.edgeInsetsFromWindow.left + self.edgeInsetsFromWindow.right);
    }
    if (h > k_appKeyWindow.frame.size.height) {
        h = k_appKeyWindow.frame.size.height - (self.edgeInsetsFromWindow.top + self.edgeInsetsFromWindow.bottom);
    }
    
    effectView_size = CGSizeMake(w, h);
    
    // 2.计算 effectView 的 autoLayout 定位 和 autoLayout 偏移
    CGRect targetRectInWindow = [self.targetView convertRect:self.targetView.bounds toView:k_appKeyWindow]; // targetView 在 window 上的 rect
        // 2.1 计算出 effectView 在 autoLayout 中的 center
    CGFloat centerX = CGRectGetMidX(targetRectInWindow) - k_appKeyWindow.bounds.size.width / 2;
    CGFloat centerY = CGRectGetMidY(targetRectInWindow) - k_appKeyWindow.bounds.size.height / 2;
        // 2.2 根据 self.pointingPosition 计算 effectView center 相对于 targetView center 的偏移
    CGFloat top = 0;
    CGFloat left = 0;
    CGFloat bottom = 0;
    CGFloat right = 0;
    if (CZArrowMenuPointingPosition_Top == self.pointingPosition) {
        top = targetRectInWindow.size.height * .5f + effectView_size.height * .5f;
    }
    if (CZArrowMenuPointingPosition_Left == self.pointingPosition) {
        left = targetRectInWindow.size.width * .5f + effectView_size.width * .5f;
    }
    if (CZArrowMenuPointingPosition_Bottom == self.pointingPosition) {
        bottom = targetRectInWindow.size.height * -.5f + effectView_size.height * -.5f;
    }
    if (CZArrowMenuPointingPosition_Right == self.pointingPosition) {
        right = targetRectInWindow.size.width * -.5f + effectView_size.width * -.5f;
    }
    
    // 3.判断 effectView 是否超出屏幕显示, 并计算是否可修复, 返回修复的结果
    CZArrowMenuBeyondScreenJudgeResult result = [self judgeEffectViewIsBeyondScreenWithTargetViewCenter:CGPointMake(CGRectGetMidX(targetRectInWindow), CGRectGetMidY(targetRectInWindow)) effectViewSize:effectView_size targetViewRectInWindow:targetRectInWindow];
    
    CGSize t_s = CGSizeEqualToSize(result.size, CGSizeZero) ? effectView_size : result.size;
    
    CZArrowCenterPosition t_p = CZArrowCenterPositionMake(self.pointingPosition,
                                                          top + result.offset.top + result.sizeOffset.top,
                                                          left + result.offset.left + result.sizeOffset.left,
                                                          bottom - result.offset.bottom - result.sizeOffset.bottom,
                                                          right - result.offset.right - result.sizeOffset.right,
                                                          centerX, centerY);
    EffectViewRectInfo rectInfo = {t_p, t_s};
    return rectInfo;
}

/**
 判断 effectView 是否超出屏幕显示, 分为两种情况, 1.因为定位问题而超出屏幕. 2.因为宽高超出屏幕
 通过 targetView 位置 以及 effectView 的大小 修复 effectView 的定位 以及 宽高
 返回 修复的结果
 */
- (CZArrowMenuBeyondScreenJudgeResult)judgeEffectViewIsBeyondScreenWithTargetViewCenter:(CGPoint)targetViewCenter effectViewSize:(CGSize)effectViewSize targetViewRectInWindow:(CGRect)targetRectInWindow
{
    // 先计算出 effectView 在 window 上的 Rect
    CGPoint effectViewOrigin = CGPointZero;
    if (CZArrowMenuPointingPosition_Top == self.pointingPosition) {
        effectViewOrigin = CGPointMake(targetViewCenter.x - effectViewSize.width * .5f, targetViewCenter.y - (targetRectInWindow.size.height * .5f + effectViewSize.height));
    }
    if (CZArrowMenuPointingPosition_Left == self.pointingPosition) {
        effectViewOrigin = CGPointMake(targetViewCenter.x - (targetRectInWindow.size.width * .5f + effectViewSize.width), targetViewCenter.y - effectViewSize.height * .5f);
    }
    if (CZArrowMenuPointingPosition_Bottom == self.pointingPosition) {
        effectViewOrigin = CGPointMake(targetViewCenter.x - effectViewSize.width * .5f, targetViewCenter.y + (targetRectInWindow.size.height * .5f));
    }
    if (CZArrowMenuPointingPosition_Right == self.pointingPosition) {
        effectViewOrigin = CGPointMake(targetViewCenter.x + (targetRectInWindow.size.width * .5f), targetViewCenter.y - effectViewSize.height * .5f);
    }

    CGRect effectViewRect = {effectViewOrigin, effectViewSize};
    CGRect edgeRect = CGRectMake(self.edgeInsetsFromWindow.left, self.edgeInsetsFromWindow.top, k_appKeyWindow.bounds.size.width - self.edgeInsetsFromWindow.left - self.edgeInsetsFromWindow.right, k_appKeyWindow.bounds.size.height - self.edgeInsetsFromWindow.top - self.edgeInsetsFromWindow.bottom);
    
    CGRect interRec = CGRectZero;
    BOOL isBeyond = YES;
    NSInteger timeout = (k_appKeyWindow.frame.size.height * .5f);    // 最多尝试计算 (屏幕高度 / 2) 次
    UIEdgeInsets autoLayoutOffset = UIEdgeInsetsZero;
    // 获取偏移方向
    OffsetDirection offsetDir = [self offsetDirectionWithCenter:targetViewCenter pointingPosition:self.pointingPosition];
    while (isBeyond && timeout > 0) {
        interRec = CGRectIntersection(edgeRect, effectViewRect);
        // 当 pointingPosition 是指向 targetView 的 上 或 下 的时候, 仅通过 判断 effectView 的宽是否完全显示在屏幕上即可, 同理, 当 pointingPosition 是指向 targetView 的 左或右, 仅通过 判断 effectView 的高, 是否完全显示在屏幕上即可
        // 务必向上取整
        isBeyond = (CZArrowMenuPointingPosition_Top == self.pointingPosition || CZArrowMenuPointingPosition_Bottom == self.pointingPosition) ? ceil(effectViewSize.width) != ceil(interRec.size.width) : ceil(effectViewSize.height) != ceil(interRec.size.height);
        timeout--;
        if (!isBeyond) break;
        // 根据不同的 箭头指向, 尝试移动 x,y 以使 effectView 完整地显示在屏幕里
        // 决定 左移, 上移, 右移, 下移的因素 是 判断 targetViewCenter 在屏幕四个方位的哪个位置
        if (CZArrowMenuPointingPosition_Top == self.pointingPosition || CZArrowMenuPointingPosition_Bottom == self.pointingPosition) {
            effectViewOrigin.x = offsetDir == OffsetDirection_left ? effectViewOrigin.x - 1 : effectViewOrigin.x + 1;
            autoLayoutOffset = offsetDir == OffsetDirection_left ? UIEdgeInsetsMake(0, (k_appKeyWindow.frame.size.height * .5f - timeout), 0, 0) : UIEdgeInsetsMake(0, 0, 0, (k_appKeyWindow.frame.size.height * .5f - timeout));
        }
        if (CZArrowMenuPointingPosition_Right == self.pointingPosition || CZArrowMenuPointingPosition_Left == self.pointingPosition) {
            effectViewOrigin.y = offsetDir == OffsetDirection_top ? effectViewOrigin.y - 1 : effectViewOrigin.y + 1;
            autoLayoutOffset = offsetDir == OffsetDirection_top ? UIEdgeInsetsMake((k_appKeyWindow.frame.size.height * .5f - timeout), 0, 0, 0) : UIEdgeInsetsMake(0, 0, (k_appKeyWindow.frame.size.height * .5f - timeout), 0);
        }
        effectViewRect = CGRectMake(effectViewOrigin.x, effectViewOrigin.y, effectViewSize.width, effectViewSize.height);
    }
    
    // 检查是否因为 宽高 的因素超出屏幕, 如果是, 调整宽高
    /*
     针对 bottom, top 这两种对 targetView 的指向情况, 仅仅调整 effectView.size.height
     针对 left, right 这两种对 targetView 的指向情况, 仅仅调整 effectView.size.width
    */
    CGSize newSize = CGSizeZero;
    UIEdgeInsets sizeOffset = UIEdgeInsetsZero; // 因为调整了 size, 且 定位使用的是 autoLayout 的 center, 所以当 size 变化, 就会造成 定位出错, 需要这个属性记录偏移
    if (CZArrowMenuPointingPosition_Top == self.pointingPosition || CZArrowMenuPointingPosition_Bottom == self.pointingPosition) {
        // 如果 effectView 和 keyWindow 的相交高度 达不到 keywindow 的 40%, 则不做重定义 size 处理, 可以确定是 框架使用者设置 position 设置不正确
        if (interRec.size.height > k_appKeyWindow.bounds.size.height * .4f) {
            newSize = CGSizeMake(effectViewSize.width, interRec.size.height);
            if (CZArrowMenuPointingPosition_Top == self.pointingPosition) {
                sizeOffset.bottom = fabs(effectViewSize.height - interRec.size.height) * .5f;
            }
            if (CZArrowMenuPointingPosition_Bottom == self.pointingPosition) {
                sizeOffset.top = fabs(effectViewSize.height - interRec.size.height) * .5f;
            }
        }
    }
    if (CZArrowMenuPointingPosition_Right == self.pointingPosition || CZArrowMenuPointingPosition_Left == self.pointingPosition) {
        // 如果 effectView 和 keyWindow 的相交宽度 达不到 keywindow 的 40%, 则不做重定义 size 处理, 可以确定是 框架使用者设置 position 设置不正确
        if (interRec.size.width > k_appKeyWindow.bounds.size.width * .4f) {
            newSize = CGSizeMake(interRec.size.width, effectViewSize.height);
            if (CZArrowMenuPointingPosition_Left == self.pointingPosition) {
                sizeOffset.right = fabs(effectViewSize.width - interRec.size.width) * .5f;
            }
            if (CZArrowMenuPointingPosition_Right == self.pointingPosition) {
                sizeOffset.left = fabs(effectViewSize.width - interRec.size.width) * .5f;
            }
        }
    }
    CZArrowMenuBeyondScreenJudgeResult re = {isBeyond, autoLayoutOffset, newSize, sizeOffset};
    return re;
}

/**
 在尝试计算偏移时, 通过 pointPosition 和 targetView center 来判断应该往 左上右下 四个方向中的哪一个方向偏移
 */
- (OffsetDirection)offsetDirectionWithCenter:(CGPoint)center pointingPosition:(CZArrowMenuPointingPosition)pointPosition
{
    if (CZArrowMenuPointingPosition_Top == self.pointingPosition || CZArrowMenuPointingPosition_Bottom == self.pointingPosition) {
        return (center.x < k_appKeyWindow.bounds.size.width / 2) ? OffsetDirection_right : OffsetDirection_left;
    }
    if (CZArrowMenuPointingPosition_Left == self.pointingPosition || CZArrowMenuPointingPosition_Right == self.pointingPosition) {
        return (center.y < k_appKeyWindow.bounds.size.height / 2) ? OffsetDirection_bottom : OffsetDirection_top;
    }
    return 0;
}

- (CAShapeLayer *)createMaskLayer
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.lineJoin = kCALineJoinRound;
    maskLayer.lineCap = kCALineCapRound;
    
    [self layoutIfNeeded];
    [self updateConstraintsIfNeeded];
    
    // 获取 targetView 的 四条边的 中点 在 keyWindow 上的 位置
    CGPoint arrowCenterInEffectView = [self calculateArrawCenterInEffectView];
    
    CGSize contentSize = self.effectView.frame.size;
    // 已知 等边三角形高度, 求等边三角形的边长
    CGFloat lengthOfSide = k_arrowHeight / k_triangleRatio;
    
    CGFloat maskX = 0;
    CGFloat maskY = 0;
    CGFloat maskW = contentSize.width;
    CGFloat maskH = contentSize.height;
    
    CGFloat move2PointX = 0;
    CGFloat move2PointY = 0;
    
    CGFloat addLine2PointX_firstStep = 0;
    CGFloat addLine2PointY_firstStep = 0;
    
    CGFloat addLine2PointX_secondStep = 0;
    CGFloat addLine2PointY_secondStep = 0;
    
    if (self.pointingPosition == CZArrowMenuPointingPosition_Left) {
        maskW = contentSize.width - k_arrowHeight;
        maskH = contentSize.height;
        
        move2PointX = contentSize.width - k_arrowHeight;
        move2PointY = arrowCenterInEffectView.y - lengthOfSide * .5f;
        
        addLine2PointX_firstStep = contentSize.width;
        addLine2PointY_firstStep = (lengthOfSide / 2) + move2PointY;
        
        addLine2PointX_secondStep = move2PointX;
        addLine2PointY_secondStep = lengthOfSide + move2PointY;
    }
    if (self.pointingPosition == CZArrowMenuPointingPosition_Right) {
        maskW = contentSize.width - k_arrowHeight;
        maskH = contentSize.height;
        
        maskX = k_arrowHeight;
        
        move2PointX = k_arrowHeight;
        move2PointY = arrowCenterInEffectView.y - lengthOfSide * .5f;
        
        addLine2PointX_firstStep = 0;
        addLine2PointY_firstStep = (lengthOfSide / 2) + move2PointY;
        
        addLine2PointX_secondStep = move2PointX;
        addLine2PointY_secondStep = lengthOfSide + move2PointY;
    }
    if (self.pointingPosition == CZArrowMenuPointingPosition_Top) {
        maskW = contentSize.width;
        maskH = contentSize.height - k_arrowHeight;
        
        move2PointX = arrowCenterInEffectView.x - lengthOfSide * .5f;
        move2PointY = contentSize.height - k_arrowHeight;
        
        addLine2PointX_firstStep = (lengthOfSide / 2) + move2PointX;
        addLine2PointY_firstStep = contentSize.height;
        
        addLine2PointX_secondStep = lengthOfSide + move2PointX;
        addLine2PointY_secondStep = move2PointY;
    }
    if (self.pointingPosition == CZArrowMenuPointingPosition_Bottom) {
        maskW = contentSize.width;
        maskH = contentSize.height - k_arrowHeight;
        
        maskY = k_arrowHeight;
        
        move2PointX = arrowCenterInEffectView.x - lengthOfSide * .5f;
        move2PointY = k_arrowHeight;
        
        addLine2PointX_firstStep = (lengthOfSide / 2) + move2PointX;
        
        addLine2PointX_secondStep = lengthOfSide + move2PointX;
        addLine2PointY_secondStep = k_arrowHeight;
    }
    UIBezierPath *b_path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(maskX, maskY, maskW, maskH) cornerRadius:k_cornerRadius];
    // 利用 CAShapeLayer 画尖角
    [b_path moveToPoint:CGPointMake(move2PointX, move2PointY)];
    [b_path addLineToPoint:CGPointMake(addLine2PointX_firstStep, addLine2PointY_firstStep)];
    [b_path addLineToPoint:CGPointMake(addLine2PointX_secondStep, addLine2PointY_secondStep)];
    [b_path closePath];
    
    maskLayer.path = b_path.CGPath;
    return maskLayer;
}

/**
 计算 targetView 的 四边 中点 在 keyWindow 上 的 位置
 */
- (CGPoint)targetViewSideOfCenterInKeyWindow
{
    CGPoint t_p = [self.targetView convertPoint:CGPointMake(CGRectGetMidX(self.targetView.bounds), CGRectGetMidY(self.targetView.bounds)) toView:k_appKeyWindow];
    CGRect t_r = [self.targetView convertRect:self.targetView.bounds toView:k_appKeyWindow];

    if (CZArrowMenuPointingPosition_Top == self.pointingPosition) {
        t_p.y = t_p.y - t_r.size.height * .5f;
    }
    if (CZArrowMenuPointingPosition_Left == self.pointingPosition) {
        t_p.x = t_p.x - t_r.size.width * .5f;
    }
    if (CZArrowMenuPointingPosition_Bottom == self.pointingPosition) {
        t_p.y = t_p.y + t_r.size.height * .5f;
    }
    if (CZArrowMenuPointingPosition_Right == self.pointingPosition) {
        t_p.x = t_p.x + t_r.size.width * .5f;
    }
    return t_p;
}

- (CGPoint)calculateArrawCenterInEffectView
{
    CGPoint targetSideCenterInWindow = [self targetViewSideOfCenterInKeyWindow];
    // 将 targetView 对应的边的中点转换为 self.effectView 的坐标
    CGPoint t_p = [self convertPoint:targetSideCenterInWindow toView:self.effectView];
    if (CZArrowMenuPointingPosition_Top == self.pointingPosition) {
        t_p.y = self.effectView.bounds.size.height - k_arrowHeight;
    }
    if (CZArrowMenuPointingPosition_Left == self.pointingPosition) {
        t_p.x = self.effectView.bounds.size.width - k_arrowHeight;
    }
    if (CZArrowMenuPointingPosition_Bottom == self.pointingPosition) {
        t_p.y = k_arrowHeight;
    }
    if (CZArrowMenuPointingPosition_Right == self.pointingPosition) {
        t_p.x = k_arrowHeight;
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

- (void)dismiss
{
    __weak __typeof (self) weakSelf = self;
    CGAffineTransform transform_s = CGAffineTransformMakeScale(.1f, .1f);
    CGAffineTransform transform_t = self.effectViewTransform;
    [UIView animateWithDuration:.13f animations:^{
        weakSelf.effectView.transform = CGAffineTransformConcat(transform_s, transform_t);
        weakSelf.effectView.alpha = 0;
        weakSelf.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void)reloadItems
{
    if (self.direction == CZArrowMenuDirection_Horizontal){
        NSArray <CZArrowMenuCollectionViewCell *>*visibleCells = [self.collectionView visibleCells];
        [visibleCells enumerateObjectsUsingBlock:^(CZArrowMenuCollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.item = obj.item;
        }];
    }
    if (self.direction == CZArrowMenuDirection_Vertical){
        NSArray <CZArrowMenuTableViewCell *>*visibleCells = [self.tableView visibleCells];
        [visibleCells enumerateObjectsUsingBlock:^(CZArrowMenuTableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.item = obj.item;
        }];
    }
}

- (void)reload
{
    if (self.direction == CZArrowMenuDirection_Horizontal){
        [self.collectionView reloadData];
    }
    if (self.direction == CZArrowMenuDirection_Vertical){
        [self.tableView reloadData];
    }
}

#pragma mark - Notification
- (void)deviceOrientationDidChangeNotification:(NSNotification *)sender
{
    [self confirmContentRect];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
