//
//  ZFAsyncLayer.m
//  FMAsyncDisplayAttributedLabel
//
//  Created by 邝战锋 on 2017/7/11.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import "ZFAsyncLayer.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

static dispatch_queue_t ZFAsyncLayerGetDisplayQueue() {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queue[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        //创建队列
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queue[i] = dispatch_queue_create("com.maple.asyncLayer.render", attr);
            }
        } else {
            for (NSInteger i = 0; i < queueCount; i++) {
                queue[i] = dispatch_queue_create("com.maple.asyncLayer.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queue[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) {
        cur = - cur;
    }
    return queue[(cur) % queueCount];
}

static dispatch_queue_t ZFAsyncLayerGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}




@implementation ZFAsyncLayer

#pragma mark - Override
+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"displaysAsynchronously"]) {
        return @(YES);
    } else {
        return [super defaultValueForKey:key];
    }
}

- (instancetype)init {
    self = [super init];
    static CGFloat scale;
    static dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    self.contentsScale = scale;
    _displaysAsynchronously = YES;
    return self;
}

- (void)setNeedsDisplay {
    [self _cancelAsyncDisplay];
    [super setNeedsDisplay];
}

- (void)display {
    super.contents = super.contents;
    [self _displayAsync:_displaysAsynchronously];
}

#pragma mark - private
- (void)_displayAsync:(BOOL)async {
    __strong id<ZFAsyncDisplayDelegate> delegate = (id)self.delegate;
    ZFAsyncDisplayTask *task = [delegate newAsyncDisplayTask];
    //无绘制
    if (!task.display) {
        if (task.willDisplay) {
            task.willDisplay(self);
        }
        //置空内容
        self.contents = nil;
        if (task.didDisplay) {
            task.didDisplay(self, YES);;
        }
    }
    
    //异步绘制
    if (async) {
        if (task.willDisplay) {
            task.willDisplay(self);
        }
        int32_t value = self.value;
        BOOL (^isCancel)() = ^BOOL(){
            return value != self.value;
        };
        CGSize size = self.bounds.size;
        BOOL opaque = self.opaque;
        CGFloat scale = self.contentsScale;
        CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
        if (size.width < 1 || size.height < 1) {
            CGImageRef image = (__bridge_retained CGImageRef)(self.contents);
            self.contents = nil;
            if (image) {
                dispatch_async(ZFAsyncLayerGetReleaseQueue(), ^{
                    CFRelease(image);
                });
                if (task.didDisplay) {
                    task.didDisplay(self, YES);
                }
                CGColorRelease(backgroundColor);
                return;
            }
        }
        //
        dispatch_async(ZFAsyncLayerGetDisplayQueue(), ^{
            if (isCancel()) {
                CGColorRelease(backgroundColor);
                return;
            }
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            if (opaque) {
                CGContextSaveGState(context); {
                    if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                        CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                        CGContextFillPath(context);
                    }
                    if (backgroundColor) {
                        CGContextSetFillColorWithColor(context, backgroundColor);
                        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
                        CGContextFillPath(context);
                    }
                } CGContextRestoreGState(context);
                CGColorRelease(backgroundColor);
            }
            task.display(context, size, isCancel);
            //取消绘制
            if (isCancel()) {
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didDisplay) {
                        task.didDisplay(self, NO);
                    }
                });
                return;
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancel()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didDisplay) {
                        task.didDisplay(self, NO);
                    }
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCancel()) {
                    if (task.didDisplay) {
                        task.didDisplay(self, NO);
                    }
                } else {
                    self.contents = (__bridge id)image.CGImage;
                    if (task.didDisplay) {
                        task.didDisplay(self, YES);
                    }
                }
            });
        });
    } else {
        [self increase];
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentsScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (task.willDisplay) {
            task.willDisplay(self);
        }
        if (self.opaque) {
            CGSize size = self.bounds.size;
            size.width *= self.contentsScale;
            size.height *= self.contentsScale;
            CGContextSaveGState(context); {
                if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(context, self.backgroundColor);
                    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                }
                if (self.backgroundColor) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                }
            } CGContextRestoreGState(context);
        }
        task.display(context, self.bounds.size, ^{return NO;});
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id)image.CGImage;
        if (task.didDisplay) {
            task.didDisplay(self, YES);
        }
    }
}

- (void)_cancelAsyncDisplay {
    [self increase];
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end



















