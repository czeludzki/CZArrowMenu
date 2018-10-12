//
//  CZArrowMenuTableViewCell.m
//  CZArrowMenu
//
//  Created by siu on 2018/10/13.
//

#import "CZArrowMenuTableViewCell.h"
#import <Masonry/Masonry.h>


@interface CZArrowMenuTableViewCell ()
@property (nonatomic, weak) UIButton *button;
@end

@implementation CZArrowMenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        
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
