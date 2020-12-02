//
//  AdvanceFullScreenVideoDelegate.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceFullScreenVideoDelegate_h
#define AdvanceFullScreenVideoDelegate_h

@protocol AdvanceFullScreenVideoDelegate <NSObject>
@optional

/// 请求广告数据成功后调用
- (void)advanceFullScreenVideoOnAdReceived;

/// 广告曝光成功
- (void)advanceFullScreenVideoOnAdShow;

/// 广告点击
- (void)advanceFullScreenVideoOnAdClicked;

/// 广告渲染失败
- (void)advanceFullScreenVideoOnAdRenderFailed;

/// 广告拉取失败
- (void)advanceFullScreenVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error;

/// 广告关闭
- (void)advanceFullScreenVideoOnAdClosed;

/// 视频播放完成
- (void)advanceFullScreenVideoOnAdPlayFinish;

/// 策略请求失败
- (void)advanceOnAdNotFilled:(NSError *)error;

@end

#endif
