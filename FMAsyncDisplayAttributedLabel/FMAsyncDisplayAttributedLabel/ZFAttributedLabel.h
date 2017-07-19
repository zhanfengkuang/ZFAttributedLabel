//
//  ZFAttributedLabel.h
//  FMAsyncDisplayAttributedLabel
//
//  Created by 邝战锋 on 2017/7/12.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFTextLayout;

@interface ZFAttributedLabel : UIView

/**
 普通文本
 */
@property (nonatomic, copy, nullable) NSString *text;

@property (nonatomic, copy) NSAttributedString *attributedString;

- (void)setTextLayout:(ZFTextLayout *)textLayout;

@end

NS_ASSUME_NONNULL_END
