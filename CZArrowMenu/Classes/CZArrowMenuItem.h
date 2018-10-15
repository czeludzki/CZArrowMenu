//
//  CZArrowMenuItem.h
//  IAskDoctorNew
//
//  Created by siu on 10/10/2018.
//  Copyright © 2018年 IAsk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CZArrowMenuItem;
typedef void(^CZArrowMenuItemHandler)(CZArrowMenuItem *item, NSInteger index);

NS_ASSUME_NONNULL_BEGIN

@interface CZArrowMenuItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy, readonly) CZArrowMenuItemHandler handler;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image handler:(CZArrowMenuItemHandler)handler;
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
