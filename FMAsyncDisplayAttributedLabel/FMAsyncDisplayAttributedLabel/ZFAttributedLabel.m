//
//  ZFAttributedLabel.m
//  FMAsyncDisplayAttributedLabel
//
//  Created by 邝战锋 on 2017/7/12.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import "ZFAttributedLabel.h"
#import "ZFTextLayout.h"
#import <CoreText/CoreText.h>
#import "ZFAsyncLayer.h"

@interface ZFAttributedLabel ()

@property (nonatomic, strong) ZFTextLayout *textLayout;
@property (nonatomic, assign) BOOL ignoreRedraw;

@end


@implementation ZFAttributedLabel {
    CTFrameRef _textFrame;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

/*
 软件组成：
    GPU的高并发是为了让它高性能的将不同的纹理合成起来
    open Graphics(['ɡræfiks]) library (OpenGL)提供一个2D和3D渲染的API。
 */

/*
 硬件参与者：
    GPU将每一个*frame*合成一个纹理(位图)合成在一块(一秒60次保证不会出现卡顿)
    合成的纹理被放置到VRAM(显存)
 
 */

//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        
//    }
//    return self;
//    
//    
//    
//}

#pragma mark - private
- (void)resetTextFrame {
    if (_textFrame) {
        CFRelease(_textFrame);
    }
    [self.layer setNeedsLayout];
}

#pragma mark - 设置文本
- (void)setText:(NSString *)text {
}

#pragma mark - Override
+ (Class)layerClass {
    return ZFAsyncLayer.class;
}

#pragma mark - ZFAsyncLayerDelegate
- (ZFAsyncDisplayTask *)newAsyncDisplayTask {
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithAttributedString:self.textLayout.attributedString];
    ZFAsyncDisplayTask *task = [ZFAsyncDisplayTask new];
//    __weak __typeof(self)weakSelf = self;
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        layer.contentsScale = 2;
    };
    
    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancel)(void)) {
        if (isCancel) {
            return;
        }
        if (!attributedString.length) {
            return;
        }
//        [weakSelf drawWithContext:context withSize:size];
    };
    
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        
    };
    return task;
}

//- (void)drawWithContext:(CGContextRef)context withSize:(CGSize)size {
//    CFArrayRef lines = CTFrameGetLines(_textFrame);
////    NSInteger numberOfLines = [self numberOfDisplayedLines];
//    
//    NSInteger numberOfLines = _textLayout.numberOfLines;
//    NSInteger lineBreakMode = _textLayout.lineBreakMode;
//    
//    CGPoint lineOrigins[numberOfLines];
//    CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, numberOfLines), lineOrigins);
//    
//    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++)
//    {
//        CGPoint lineOrigin = lineOrigins[lineIndex];
//        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
//        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
//        
//        BOOL shouldDrawLine = YES;
//        if (lineIndex == numberOfLines - 1 &&
//            lineBreakMode == kCTLineBreakByTruncatingTail)
//        {
////            //找到最后一行并检查是否需要 truncatingTail
////            CFRange lastLineRange = CTLineGetStringRange(line);
////            if (lastLineRange.location + lastLineRange.length < attributedString.length)
////            {
////                CTLineTruncationType truncationType = kCTLineTruncationEnd;
////                NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
////                
////                NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition
////                                                                     effectiveRange:NULL];
////                NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:M80EllipsesCharacter
////                                                                                  attributes:tokenAttributes];
////                CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
////                
////                NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
////                
////                if (lastLineRange.length > 0)
////                {
////                    //移除掉最后一个对象...（其实这个地方有点问题,也有可能需要移除最后 2 个对象，因为 attachment 宽度的关系）
////                    [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
////                }
////                [truncationString appendAttributedString:tokenString];
////                
////                
////                CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
////                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
////                if (!truncatedLine)
////                {
////                    truncatedLine = CFRetain(truncationToken);
////                }
////                CFRelease(truncationLine);
////                CFRelease(truncationToken);
////                
////                CTLineDraw(truncatedLine, context);
////                CFRelease(truncatedLine);
////                ////

////                shouldDrawLine = NO;
//            }
//        }
//        
////        if(shouldDrawLine)
////        {
////            CTLineDraw(line, context);
////        }
////    
////    }
//}




@end













