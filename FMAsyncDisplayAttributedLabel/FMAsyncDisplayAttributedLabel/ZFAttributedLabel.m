//
//  ZFAttributedLabel.m
//  FMAsyncDisplayAttributedLabel
//
//  Created by 邝战锋 on 2017/7/12.
//  Copyright © 2017年 Maple. All rights reserved.
//

#import "ZFAttributedLabel.h"


@implementation ZFAttributedLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}



#pragma mark - ZFAsyncLayerDelegate
+ (Class)layerClass {
    return ZFAsyncLayer.class;
}

- (ZFAsyncDisplayTask *)newAsyncDisplayTask {
//    NSAttributedString *attributedString = []
    ZFAsyncDisplayTask *task = [ZFAsyncDisplayTask new];
    __weak __typeof(&*self)weakSelf = self;
    
    
    return task;
}




@end













