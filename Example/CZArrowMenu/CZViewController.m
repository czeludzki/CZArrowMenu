//
//  CZViewController.m
//  CZArrowMenu
//
//  Created by czeludzki on 10/11/2018.
//  Copyright (c) 2018 czeludzki. All rights reserved.
//

#import "CZViewController.h"
#import <CZArrowMenu/CZArrowMenu.h>

@interface CZViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn_left_top;
@property (weak, nonatomic) IBOutlet UIButton *btn_right_top;
@property (weak, nonatomic) IBOutlet UIButton *btn_mid;
@property (weak, nonatomic) IBOutlet UIButton *btn_left_bottom;
@property (weak, nonatomic) IBOutlet UIButton *btn_right_bottom;

@end

@implementation CZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnOnClick:(UIButton *)sender {
    CZArrowMenuItem *item0 = [[CZArrowMenuItem alloc] init];
    item0.title = @"000";
    item0.img = [UIImage imageNamed:@"front_btn_bold"];
    
    CZArrowMenuItem *item1 = [[CZArrowMenuItem alloc] init];
    item1.title = @"1111";
    item1.img = [UIImage imageNamed:@"front_btn_italic"];
    
    CZArrowMenuItem *item2 = [[CZArrowMenuItem alloc] init];
//    item2.title = @"222222";
    item2.selected = YES;
    item2.img = [UIImage imageNamed:@"front_btn_h1"];
    
    CZArrowMenuItem *item3 = [[CZArrowMenuItem alloc] init];
//    item3.title = @"333";
    item3.img = [UIImage imageNamed:@"front_btn_h2"];
    
    CZArrowMenuItem *item4 = [[CZArrowMenuItem alloc] init];
//    item4.title = @"44";
    item4.img = [UIImage imageNamed:@"front_btn_h3"];
    
    CZArrowMenuItem *item5 = [[CZArrowMenuItem alloc] init];
    item5.img = [UIImage imageNamed:@"front_btn_h3"];

    CZArrowMenuItem *item6 = [[CZArrowMenuItem alloc] init];
    item6.img = [UIImage imageNamed:@"front_btn_h3"];
    
    CZArrowMenuItem *item7 = [[CZArrowMenuItem alloc] init];
    item7.img = [UIImage imageNamed:@"front_btn_h3"];
    
    CZArrowMenuItem *item8 = [[CZArrowMenuItem alloc] init];
    item8.img = [UIImage imageNamed:@"front_btn_h3"];
    
    CZArrowMenuItem *item9 = [[CZArrowMenuItem alloc] init];
    item9.img = [UIImage imageNamed:@"front_btn_h3"];
    
//    CZArrowMenu *m = [[CZArrowMenu alloc] initWithDirection:CZArrowMenuDirection_Vertical Items:@[item0, item1, item2, item3, item4, item5, item6, item7, item8, item9]];
    CZArrowMenu *m = [[CZArrowMenu alloc] initWithDirection:CZArrowMenuDirection_Vertical Items:@[item0, item1, item2, item3]];
    [m showWithArrowTarget:sender pointingPosition:CZArrowMenuPointingPosition_Left];
}

@end
