//
//  Classes.h
//  CY_FMDB
//
//  Created by 薛国宾 on 16/4/13.
//  Copyright © 2016年 千里之行始于足下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transcript.h"

@interface Classes : NSObject

@property (copy, nonatomic) NSString *studentID;
@property (copy, nonatomic) NSString *studentName;
@property (copy, nonatomic) NSString *studentSex;

@property (strong, nonatomic) Transcript *transcript;

@end
