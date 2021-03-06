//
//  MercurySplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "MercurySplashAdapter.h"

#if __has_include(<MercurySDK/MercurySplashAd.h>)
#import <MercurySDK/MercurySplashAd.h>
#else
#import "MercurySplashAd.h"
#endif

#import "AdvSupplierModel.h"
#import "AdvanceSplash.h"
#import "AdvLog.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface MercurySplashAdapter () <MercurySplashAdDelegate>
@property (nonatomic, strong) MercurySplashAd *mercury_ad;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, weak) AdvanceSplash *adspot;

@end

@implementation MercurySplashAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceSplash *)adspot {
    if ([self init]) {
        _adspot = adspot;
        _supplier = supplier;
    }
    return self;
}

- (void)loadAd {
    _mercury_ad = [[MercurySplashAd alloc] initAdWithAdspotId:_supplier.adspotid delegate:self];
    _mercury_ad.placeholderImage = _adspot.backgroundImage;
    _mercury_ad.logoImage = _adspot.logoImage;
    if (_adspot.showLogoRequire) {
        _mercury_ad.showType = MercurySplashAdShowCutBottom;
    }
    if (_adspot.timeout) {
        if (_adspot.timeout > 500) {
            _mercury_ad.fetchDelay = _supplier.timeout / 1000.0;
        }
    }
    _mercury_ad.delegate = self;
    _mercury_ad.controller = _adspot.viewController;

    [_mercury_ad loadAdAndShow];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

- (void)deallocAdapter {
    
    id timer0 = [_mercury_ad performSelector:@selector(timer0)];
    [timer0 performSelector:@selector(stopTimer)];

    
    id timer = [_mercury_ad performSelector:@selector(timer)];
    [timer performSelector:@selector(stopTimer)];
    
    UIViewController *vc = [_mercury_ad performSelector:@selector(splashVC)];
    [vc dismissViewControllerAnimated:NO completion:nil];
    [vc.view removeFromSuperview];
    
    self.delegate = nil;
    _mercury_ad.delegate = nil;
    _mercury_ad = nil;

        
}

// MARK: ======================= MercurySplashAdDelegate =======================
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd {

    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)] && self.mercury_ad) {

        [self.delegate advanceExposured];
    }
}

- (void)mercury_splashAdFailError:(nullable NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
//    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceSplashOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

- (void)mercury_splashAdLifeTime:(NSUInteger)time {
    if (time <= 0 && [self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
        [self.delegate advanceSplashOnAdCountdownToZero];
    }
}

- (void)mercury_splashAdSkipClicked:(MercurySplashAd *)splashAd {
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
        [self.delegate advanceSplashOnAdSkipClicked];
    }
}

- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

@end
