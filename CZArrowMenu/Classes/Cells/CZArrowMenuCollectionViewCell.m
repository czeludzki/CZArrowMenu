//
//  CZArrowMenuCollectionViewCell.m
//  CZArrowMenu
//
//  Created by siu on 11/10/2018.
//

#import "CZArrowMenuCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface CZArrowMenuCollectionViewCell ()
@property (nonatomic, weak) UIButton *button;
@end

@implementation CZArrowMenuCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.contentView addSubview:button];
        self.button = button;
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

- (void)setItem:(CZArrowMenuItem *)item
{
    _item = item;
    self.button.tintColor = _item.selected ? _item.selectedColor : _item.tintColor;
    self.button.titleLabel.font = _item.font;
    [self.button setTitle:_item.title forState:UIControlStateNormal];
    [self.button setImage:_item.img forState:UIControlStateNormal];
}

@end
