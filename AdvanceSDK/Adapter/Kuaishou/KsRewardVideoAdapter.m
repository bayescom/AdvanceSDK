//
//  KsRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "KsRewardVideoAdapter.h"
#if __has_include(<KSAdSDK/KSAdSDK.h>)
#import <KSAdSDK/KSAdSDK.h>
#else
//#import "KSAdSDK.h"
#endif

#import "AdvanceRewardVideo.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"
@interface KsRewardVideoAdapter ()<KSRewardedVideoAdDelegate>
@property (nonatomic, strong) KSRewardedVideoAd *ks_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation KsRewardVideoAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceRewardVideo *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        KSRewardedVideoModel *model = [KSRewardedVideoModel new];
        _ks_ad = [[KSRewardedVideoAd alloc] initWithPosId:supplier.adspotid rewardedVideoModel:model];
        _ks_ad.showDirection = KSAdShowDirection_Vertical;

    }
    return self;
}

- (void)loadAd {
    
    _ks_ad.delegate = self;
    ADVLog(@"加载快手 supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"快手 成功");
        if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
            [self.delegate advanceUnifiedViewDidLoad];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"快手 失败 %@", _supplier);
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"快手 正在加载中");
    } else {
        ADVLog(@"快手 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        self.ks_ad.delegate = self;
        [self.ks_ad loadAdData];

//        [_ks_ad loadAdData];
    }
}

- (void)showAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.ks_ad.isValid) {
            [self.ks_ad showAdFromRootViewController:self.adspot.viewController.navigationController];
        }
    });

}

- (void)deallocAdapter {
    self.ks_ad = nil;
}


- (void)dealloc {
    ADVLog(@"%s", __func__);
}

/**
 This method is called when video ad material loaded successfully.
 */
- (void)rewardedVideoAdDidLoad:(KSRewardedVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    
    NSLog(@"广点通激励视频拉取成功 %@",self.ks_ad);
    if (_supplier.isParallel == YES) {
        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }

}
/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }

}
/**
 This method is called when cached successfully.
 */
- (void)rewardedVideoAdVideoDidLoad:(KSRewardedVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
}
/**
 This method is called when video ad slot will be showing.
 */
- (void)rewardedVideoAdWillVisible:(KSRewardedVideoAd *)rewardedVideoAd {
    
}
/**
 This method is called when video ad slot has been shown.
 */
- (void)rewardedVideoAdDidVisible:(KSRewardedVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}
/**
 This method is called when video ad is about to close.
 */
- (void)rewardedVideoAdWillClose:(KSRewardedVideoAd *)rewardedVideoAd {
    
}
/**
 This method is called when video ad is closed.
 */
- (void)rewardedVideoAdDidClose:(KSRewardedVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/**
 This method is called when video ad is clicked.
 */
- (void)rewardedVideoAdDidClick:(KSRewardedVideoAd *)rewardedVideoAd  {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}
/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)rewardedVideoAdDidPlayFinish:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
            [self.delegate advanceRewardVideoAdDidPlayFinish];
        }
    }
}
/**
 This method is called when the user clicked skip button.
 */
- (void)rewardedVideoAdDidClickSkip:(KSRewardedVideoAd *)rewardedVideoAd {
    
}
/**
 This method is called when the video begin to play.
 */
- (void)rewardedVideoAdStartPlay:(KSRewardedVideoAd *)rewardedVideoAd {
    
}
/**
 This method is called when the user close video ad.
 */
- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd hasReward:(BOOL)hasReward {
    if (hasReward) {
        if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective)]) {
            [self.delegate advanceRewardVideoAdDidRewardEffective];
        }
    }
}



@end
