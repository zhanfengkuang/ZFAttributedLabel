//
//  ZFAsyncLayer.h
//  FMAsyncDisplayAttributedLabel
//
//  Created by 邝战锋 on 2017/7/11.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFAsyncDisplayTask;
@interface ZFAsyncLayer : CALayer
@property (nonatomic, assign) BOOL displaysAsynchronously;
@property (nonatomic, assign) int32_t value;
@end

@protocol ZFAsyncDisplayDelegate <NSObject>
- (ZFAsyncDisplayTask *)newAsyncDisplayTask;
@end

@interface ZFAsyncDisplayTask : NSObject
@property (nullable, nonatomic, copy) void(^willDisplay)(CALayer *layer);
@property (nullable, nonatomic, copy) void(^display)(CGContextRef context, CGSize size, BOOL (^isCancel)(void));
@property (nullable, nonatomic, copy) void(^didDisplay)(CALayer *layer, BOOL finished);
@end

NS_ASSUME_NONNULL_END


