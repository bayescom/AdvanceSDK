//
//  DemoFullScreenVideoController.m
//  AdvanceSDKDev
//
//  Created by 程立卿 on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "DemoFullScreenVideoController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceFullScreenVideo.h>

@interface DemoFullScreenVideoController () <AdvanceFullScreenVideoDelegate>
@property (nonatomic, strong) AdvanceFullScreenVideo *advanceFullScreenVideo;

@end

@implementation DemoFullScreenVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200076"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithMediaId:self.mediaId
                                                                   adspotId:self.adspotId
                                                             viewController:self];
    self.advanceFullScreenVideo.delegate = self;
    [self.advanceFullScreenVideo setDefaultSdkSupplierWithMediaId:@"100255"
                                                      adspotId:@"10000559"
                                                      mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                        sdkId:SDK_ID_MERCURY];
    [self.advanceFullScreenVideo loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceFullScreenVideo showAd];
}

// MARK: ======================= AdvanceFullScreenVideoDelegate =======================

/// 请求广告数据成功后调用
- (void)advanceFullScreenVideoOnAdReceived {
    NSLog(@"请求广告数据成功后调用");
}

/// 广告渲染失败
- (void)advanceFullScreenVideoOnAdRenderFailed {
    NSLog(@"广告渲染失败");
}

/// 广告曝光成功
- (void)advanceFullScreenVideoOnAdShow {
    NSLog(@"广告曝光成功");
}

/// 广告点击
- (void)advanceFullScreenVideoOnAdClicked {
    NSLog(@"广告点击");
}

/// 广告拉取失败
- (void)advanceFullScreenVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"广告拉取失败");
}

/// 广告关闭
- (void)advanceFullScreenVideoOnAdClosed {
    NSLog(@"广告关闭");
}

/// 广告播放完成
- (void)advanceFullScreenVideoOnAdPlayFinish {
    NSLog(@"广告播放完成");
}


@end
