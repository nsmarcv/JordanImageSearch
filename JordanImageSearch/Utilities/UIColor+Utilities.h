//
//  UIColor+Utilities.h
//  JordanImageSearch
//
//  Created by Jordan Lepretre on 24/03/2018.
//  Copyright © 2018 JDN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utilities)

+ (UIColor *) colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (UIColor *) colorFromHexString:(NSString *)hexString;

@end
