//
//  HXProfile.m
//  TipTop-Adviser
//
//  Created by ShiCang on 15/11/11.
//  Copyright © 2015年 Outsourcing. All rights reserved.
//

#import "HXProfile.h"

@implementation HXProfile

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"ID": @"id",
       @"realName": @"real_name",
         @"goodAt": @"good_at",
      @"introduce": @"about"};
}

@end
