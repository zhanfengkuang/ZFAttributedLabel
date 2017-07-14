//
//  NSMutableAttributedString+ZF.m
//  FMAsyncDisplayAttributedLabel
//
//  Created by 邝战锋 on 2017/7/13.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import "NSMutableAttributedString+ZF.h"
#import <CoreText/CoreText.h>

@implementation NSMutableAttributedString (ZF)

- (void)zf_setFont:(UIFont *)font {
    [self zf_setFont:font range:NSMakeRange(0, [self length])];
}

- (void)zf_setFont:(UIFont *)font range:(NSRange)range {
    if (font) {
        [self removeAttribute:(NSString *)kCTFontAttributeName range:range];
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (fontRef) {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}


@end















