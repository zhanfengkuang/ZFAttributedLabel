//
//  ZFTextLayout.h
//  FMAsyncDisplayAttributedLabel
//
//  Created by 邝战锋 on 2017/7/12.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol ZFTextLayoutDelegate <NSObject>

- (void)resetTextFrame;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ZFTextLayout : NSObject <NSCopying>

/**
 字体大小
 */
@property (nonatomic, strong, nullable) UIFont *font;
/**
 文字颜色
 */
@property (nonatomic, strong, nullable) UIColor *textColor;
/**
 链接点击时背景高亮色
 */
@property (nonatomic, strong, nullable) UIColor *highlightColor;
/**
 链接文字颜色
 */
@property (nonatomic, strong, nullable) UIColor *linkColor;
/**
 阴影颜色
 */
@property (nonatomic, strong, nullable) UIColor *shadowColor;
/**
 阴影offset
 */
@property (nonatomic, assign) CGSize shadowOffset;
/**
 阴影半径
 */
@property (nonatomic, assign) CGFloat shadowBlur;
/**
 链接是否带下划线
 */
@property (nonatomic, assign) BOOL underLineForLink;
/**
 自动检测
 */
@property (nonatomic, assign) BOOL autoDetectLinks;
/**
 行数
 */
@property (nonatomic, assign) NSInteger numberOfLines;
/**
 文字排版样式
 */
@property (nonatomic, assign) CTTextAlignment textAlignment;
/**
 LineBreakMode
 */
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;
/**
 行间距
 */
@property (nonatomic, assign) CGFloat lineSpacing;
/**
 段间距
 */
@property (nonatomic, assign) CGFloat paragraphSpacing;
/**
 普通文本
 */
@property (nonatomic, copy, nullable) NSString *text;
/**
 属性文本
 */
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
/**
 布局后得到的文本
 */
@property (nonatomic, copy, readonly) NSMutableAttributedString *attributedString;
/**
 要显示文本的frame
 */
@property (nonatomic, assign, readonly) CGRect textLabelFrame;


//添加文本
- (void)appendText:(NSString *)text;
- (void)appendAttributedText:(NSAttributedString *)attributedText;

@end

NS_ASSUME_NONNULL_END









