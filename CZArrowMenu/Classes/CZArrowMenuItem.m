//
//  CZArrowMenuItem.m
//  IAskDoctorNew
//
//  Created by siu on 10/10/2018.
//  Copyright © 2018年 IAsk. All rights reserved.
//

#import "CZArrowMenuItem.h"

@interface CZArrowMenuItem ()

@end

@implementation CZArrowMenuItem

- (instancetype)init
{
    if (self = [super init]) {
        [self initSetup];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image
{
    if (self = [super init]) {
        [self initSetup];
        self.title = title;
        self.img = image;
    }
    return self;
}

-  (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image handler:(CZArrowMenuItemHandler)handler
{
    if (self = [super init]) {
        [self initSetup];
        self.title = title;
        self.img = image;
        _handler = handler ? : ^(CZArrowMenuItem *item, NSInteger index){};
    }
    return self;
}

- (void)initSetup
{
    self.tintColor = [UIColor whiteColor];
    self.selectedColor = [UIColor colorWithRed:255/255 green:105/255 blue:110/255 alpha:1];
    self.selected = NO;
    self.font = [UIFont boldSystemFontOfSize:14];
}

@end
