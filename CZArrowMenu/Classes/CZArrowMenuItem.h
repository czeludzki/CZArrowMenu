//
//  CZArrowMenuItem.h
//  IAskDoctorNew
//
//  Created by siu on 10/10/2018.
//  Copyright © 2018年 IAsk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CZArrowMenuItem;

typedef void(^CZArrowMenuItemHandler)(CZArrowMenuItem *item, NSInteger index);

@interface CZArrowMenuItem : NSObject
@property (nonatomic, copy) NSString * _Nullable title;
@property (nonatomic, strong) UIImage * _Nullable img;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, copy, readonly) CZArrowMenuItemHandler handler;

- (instancetype)initWithTitle:(NSString * _Nullable)title image:(UIImage * _Nullable)image handler:(CZArrowMenuItemHandler)handler;
- (instancetype)initWithTitle:(NSString * _Nullable)title image:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
