//
//  AdvanceInterstitial.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdspot.h"
#import "AdvanceSdkConfig.h"
#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceInterstitial : AdvanceBaseAdspot
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@property (nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid viewController:(UIViewController *)viewController;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
