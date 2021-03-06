//
//  AdvanceRewardVideoProtocol.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceRewardVideoProtocol_h
#define AdvanceRewardVideoProtocol_h
#import "AdvanceBaseDelegate.h"
@protocol AdvanceRewardVideoDelegate <AdvanceBaseDelegate>
@optional

/// 广告视频缓存完成
- (void)advanceRewardVideoOnAdVideoCached;

/// 广告视频播放完成
- (void)advanceRewardVideoAdDidPlayFinish;

/// 广告到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective;

@end

#endif
