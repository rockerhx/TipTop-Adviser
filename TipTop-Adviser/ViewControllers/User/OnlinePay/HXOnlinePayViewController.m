//
//  HXOnlinePayViewController.m
//  TipTop-Adviser
//
//  Created by ShiCang on 15/10/18.
//  Copyright © 2015年 Outsourcing. All rights reserved.
//

#import "HXOnlinePayViewController.h"

@interface HXOnlinePayViewController ()

@end

@implementation HXOnlinePayViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Setter And Getter
- (NSString *)navigationControllerIdentifier {
    return @"HXMyOnlinePayNavigationController";
}

- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameOnlinePay;
}

@end
