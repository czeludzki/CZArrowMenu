//
//  CZArrowMenuItem.m
//  IAskDoctorNew
//
//  Created by siu on 10/10/2018.
//  Copyright © 2018年 IAsk. All rights reserved.
//

#import "CZArrowMenuItem.h"

@implementation CZArrowMenuItem

- (instancetype)init
{
    if (self = [super init]) {
        self.tintColor = [UIColor whiteColor];
        self.selectedColor = [UIColor colorWithRed:255/255 green:105/255 blue:110/255 alpha:1];
        self.selected = NO;
        self.font = [UIFont boldSystemFontOfSize:14];
    }
    return self;
}

@end
