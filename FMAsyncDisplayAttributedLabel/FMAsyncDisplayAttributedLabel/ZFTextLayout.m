//
//  ZFTextLayout.m
//  FMAsyncDisplayAttributedLabel
//
//  Created by 邝战锋 on 2017/7/12.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import "ZFTextLayout.h"
#import <CoreText/CoreText.h>

@interface ZFTextLayout ()


@property (nonatomic,assign)    BOOL linkDetected;
@property (nonatomic,assign)    BOOL ignoreRedraw;

@end

@implementation ZFTextLayout{
    NSMutableArray *_attachments;
    NSMutableArray *_linkLocations;
    CTFrameRef _textFrame;
    CGFloat _fontAscent;
    CGFloat _fontDescent;
    CGFloat _fontHeight;
}

#pragma mark - Override
- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    if (_textFrame) {
        CFRelease(_textFrame);
    }
}

#pragma mark - initialization
- (void)commonInit {
    _attributedString = [[NSMutableAttributedString alloc] init];
    _attachments = [[NSMutableArray alloc]init];
    _linkLocations = [[NSMutableArray alloc]init];
    _textFrame = nil;
    _linkColor = [UIColor blueColor];
    _font = [UIFont systemFontOfSize:15];
    _textColor = [UIColor blackColor];
    _highlightColor = [UIColor colorWithRed:0xd7/255.0
                                              green:0xf2/255.0
                                               blue:0xff/255.0
                                              alpha:1];
    _lineBreakMode = kCTLineBreakByWordWrapping;
    _underLineForLink = YES;
    _autoDetectLinks = YES;
    _lineSpacing = 0.0;
    _paragraphSpacing = 0.0;
}

#pragma mark - private
- (void)resetTextFrame {
    if (_textFrame) {
        CFRelease(_textFrame);
        _textFrame = nil;
    }
}

#pragma mark - 设置文本
- (void)setText:(NSString *)text {
#warning 辅助方法
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
    [self setAttributedText:attributedString];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [self cleanAll];
}

- (NSString *)text {
    return [_attributedString string];
}

- (NSAttributedString *)attributedText {
    return [_attributedString copy];
}

- (void)cleanAll {
    _ignoreRedraw = NO;
    _linkDetected = NO;
    [_attachments removeAllObjects];
    [_linkLocations removeAllObjects];
#warning 清除原有view，重置frame
}

#pragma mark - 添加文本
- (void)appendText:(NSString *)text {
    
}

- (void)appendAttributedText:(NSAttributedString *)attributedText {
    
}

#pragma mark - 计算大小
- (CGSize)sizeThatFits:(CGSize)size {
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (drawString == nil) {
        return CGSizeZero;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (_numberOfLines > 0 && framesetter){
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (nil != lines && CFArrayGetCount(lines) > 0){
            NSInteger lastVisibleLineIndex = MIN(_numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, size, &fitCFRange);
    if (framesetter)
    {
        CFRelease(framesetter);
    }
    
    //hack:
    //1.需要加上额外的一部分size,有些情况下计算出来的像素点并不是那么精准
    //2.iOS7 的 CTFramesetterSuggestFrameSizeWithConstraint s方法比较残,需要多加一部分 height
    //3.iOS7 多行中如果首行带有很多空格，会导致返回的 suggestionWidth 远小于真实 width ,那么多行情况下就是用传入的 width
    if (newSize.height < _fontHeight * 2) {
        return CGSizeMake(ceilf(newSize.width) + 2.0, ceilf(newSize.height) + 4.0);
    } else {
        return CGSizeMake(size.width, ceilf(newSize.height) + 4.0);
    }
}

- (NSAttributedString *)attributedStringForDraw {
    if (_attributedString) {
        //添加排版格式
        NSMutableAttributedString *drawString = [_attributedString mutableCopy];
        
        //如果LineBreakMode为TranncateTail,那么默认排版模式改成kCTLineBreakByCharWrapping,使得尽可能地显示所有文字
        CTLineBreakMode lineBreakMode = self.lineBreakMode;
        if (self.lineBreakMode == kCTLineBreakByTruncatingTail) {
            lineBreakMode = _numberOfLines == 1 ? kCTLineBreakByTruncatingTail : kCTLineBreakByWordWrapping;
        }
        CGFloat fontLineHeight = self.font.lineHeight;  //使用全局fontHeight作为最小lineHeight
        CTParagraphStyleSetting settings[] = {
            {kCTParagraphStyleSpecifierAlignment,sizeof(_textAlignment),&_textAlignment},
            {kCTParagraphStyleSpecifierLineBreakMode,sizeof(lineBreakMode),&lineBreakMode},
            {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(_lineSpacing),&_lineSpacing},
            {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(_lineSpacing),&_lineSpacing},
            {kCTParagraphStyleSpecifierParagraphSpacing,sizeof(_paragraphSpacing),&_paragraphSpacing},
            {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(fontLineHeight),&fontLineHeight},
        };
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings,sizeof(settings) / sizeof(settings[0]));
        [drawString addAttribute:(id)kCTParagraphStyleAttributeName
                           value:(__bridge id)paragraphStyle
                           range:NSMakeRange(0, [drawString length])];
        CFRelease(paragraphStyle);
    }
    return _attributedString;
}

@end











