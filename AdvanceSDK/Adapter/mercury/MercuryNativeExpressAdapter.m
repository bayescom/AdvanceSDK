//
//  MercuryNativeExpressAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "MercuryNativeExpressAdapter.h"
#if __has_include(<MercurySDK/MercuryNativeExpressAd.h>)
#import <MercurySDK/MercuryNativeExpressAd.h>
#else
#import "MercuryNativeExpressAd.h"
#endif
#import "AdvanceNativeExpress.h"
#import "AdvLog.h"

@interface MercuryNativeExpressAdapter () <MercuryNativeExpressAdDelegete>
@property (nonatomic, strong) MercuryNativeExpressAd *mercury_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSArray<MercuryNativeExpressAdView *> * views;

@end

@implementation MercuryNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceNativeExpress *)adspot; {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _mercury_ad = [[MercuryNativeExpressAd alloc] initAdWithAdspotId:_supplier.adspotid];
        _mercury_ad.videoMuted = YES;
        _mercury_ad.videoPlayPolicy = MercuryVideoAutoPlayPolicyWIFI;
        _mercury_ad.renderSize = _adspot.adSize;

    }
    return self;
}

- (void)loadAd {
    int adCount = 1;
    _mercury_ad.delegate = self;
    ADVLog(@"加载观点通 supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"广点通 成功");
        if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [self.delegate advanceNativeExpressOnAdLoadSuccess:self.views];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"广点通 失败 %@", _supplier);
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"广点通 正在加载中");
    } else {
        ADVLog(@"广点通 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        [_mercury_ad loadAdWithCount:adCount];
    }

}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// MARK: ======================= MercuryNativeExpressAdDelegete =======================
/// 拉取原生模板广告成功 | (注意: nativeExpressAdView在此方法执行结束不被强引用，nativeExpressAd中的对象会被自动释放)
- (void)mercury_nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views {
    if (views == nil || views.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
//        if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//            [self.delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier
//                                                                 error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg": @"无广告返回"}]];
//        }
        if (_supplier.isParallel == YES) {
            _supplier.state = AdvanceSdkSupplierStateFailed;
            return;
        }

    } else if (self.adspot) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
        for (MercuryNativeExpressAdView *view in views) {
            if ([view isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
                view.controller = _controller;
            }
        }
        if (_supplier.isParallel == YES) {
            NSLog(@"修改状态: %@", _supplier);
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            self.views = views;
            return;
        }

        if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [self.delegate advanceNativeExpressOnAdLoadSuccess:views];
        }
    }
}

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoadWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }
    _mercury_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView {
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderSuccess:)]) {
        [self.delegate advanceNativeExpressOnAdRenderSuccess:nativeExpressAdView];
    }
}

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:[NSError errorWithDomain:@"广告素材渲染失败" code:301 userInfo:@{@"msg": @"广告素材渲染失败"}]];
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderFail:)]) {
        [self.delegate advanceNativeExpressOnAdRenderFail:nativeExpressAdView];
    }
}

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdShow:)]) {
        [self.delegate advanceNativeExpressOnAdShow:nativeExpressAdView];
    }
}

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdClicked:)]) {
        [self.delegate advanceNativeExpressOnAdClicked:nativeExpressAdView];
    }
}

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView {
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdClosed:)]) {
        [self.delegate advanceNativeExpressOnAdClosed:nativeExpressAdView];
    }
}

@end
