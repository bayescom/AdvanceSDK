//
//  AdvanceSplash.m
//  AdvanceSDKExample
//
//  Created by 程立卿 on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceSplash.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface AdvanceSplash () <AdvanceBaseAdspotDelegate>
@property (nonatomic, strong) id adapter;


@end

@implementation AdvanceSplash
- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid {
    if (self = [super initWithMediaId:mediaid adspotId:adspotid]) {
        self.supplierDelegate = self;
    }
    return self;
}

-  (instancetype)initWithMediaId:(NSString *)mediaid
                        adspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController {
    if (self = [self initWithMediaId:mediaid adspotId:adspotid]) {
        self.viewController = viewController;
    }
    return self;
}

// MARK: ======================= AdvanceBaseAdspotDelegate =======================
/// 加载渠道广告，将会返回渠道所需参数
/// @param sdkTag 渠道Tag
/// @param params 渠道参数
- (void)advanceBaseAdspotWithSdkTag:(NSString *)sdkTag params:(NSDictionary *)params {
    // 根据渠道id自定义初始化
    NSString *clsName = @"";
    if ([sdkTag isEqualToString:@"gdt"]) {
        clsName = @"GdtSplashAdapter";
    } else if ([sdkTag isEqualToString:@"csj"]) {
        clsName = @"CsjSplashAdapter";
    } else if ([sdkTag isEqualToString:@"bayes"]) {
        clsName = @"MercurySplashAdapter";
    }
    if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithParams:adspot:), params, self);
        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
#pragma clang diagnostic pop
    } else {
        NSLog(@"%@ 不存在", clsName);
    }
}

/// 策略请求失败
/// @param sdkTag 渠道SdkTag
/// @param error 失败原因
- (void)advanceBaseAdspotWithSdkTag:(NSString *)sdkTag error:(NSError *)error {
    NSLog(@"%@", error);
}

@end