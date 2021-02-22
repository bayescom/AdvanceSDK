//
//  AdvBaseAdapter.m
//  Demo
//
//  Created by CherryKing on 2020/11/20.
//

#import "AdvBaseAdapter.h"
#import "AdvSupplierManager.h"
#import "AdvanceSupplierDelegate.h"
#import "AdvSdkConfig.h"

@interface AdvBaseAdapter ()  <AdvSupplierManagerDelegate, AdvanceSupplierDelegate>
@property (nonatomic, strong) AdvSupplierManager *mgr;

@property (nonatomic, weak) id<AdvanceSupplierDelegate> baseDelegate;

@end

@implementation AdvBaseAdapter

-  (instancetype)initWithMediaId:(NSString *)mediaId
                        adspotId:(NSString *)adspotid {
    return [self initWithMediaId:mediaId adspotId:adspotid customExt:nil];
}

- (instancetype)initWithMediaId:(NSString *)mediaId
                       adspotId:(NSString *)adspotid
                      customExt:(NSDictionary *)ext {
    if (self = [super init]) {
        _mediaId = mediaId;
        _adspotid = adspotid;
        _ext = [ext mutableCopy];
    }
    return self;
}

- (void)loadAd {
    [self.mgr loadDataWithMediaId:_mediaId adspotId:_adspotid customExt:_ext];
}

- (void)loadNextSupplierIfHas {
    [_mgr loadNextSupplierIfHas];
}

- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType {
    [self reportWithType:repoType error:nil];
}

- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType error:(NSError *)error {
    [_mgr reportWithType:repoType error:error];
    if (repoType == AdvanceSdkSupplierRepoFaileded) {
        [_mgr loadNextSupplierIfHas];
    }
}

- (void)deallocAdapter {
    [self.mgr cacelDataTask];
    self.mgr = nil;
    self.baseDelegate = nil;
    
}

- (void)setDefaultAdvSupplierWithMediaId:(NSString *)mediaId
                                adspotId:(NSString *)adspotid
                                mediaKey:(NSString *)mediakey
                                   sdkId:(nonnull NSString *)sdkid {
    [self.mgr setDefaultAdvSupplierWithMediaId:mediaId adspotId:adspotid mediaKey:mediakey sdkId:sdkid];
}

// MARK: ======================= AdvSupplierManagerDelegate =======================
/// 加载策略Model成功
- (void)advSupplierManagerLoadSuccess:(AdvSupplierModel *)model {
    if ([_baseDelegate respondsToSelector:@selector(advanceBaseAdapterLoadSuccess:)]) {
        [_baseDelegate advanceBaseAdapterLoadSuccess:model];
    }
}

/// 加载策略Model失败
- (void)advSupplierManagerLoadError:(NSError *)error {
    if ([_baseDelegate respondsToSelector:@selector(advanceBaseAdapterLoadError:)]) {
        [_baseDelegate advanceBaseAdapterLoadError:error];
    }
}

/// 返回下一个渠道的参数
- (void)advSupplierLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {

    // 初始化渠道参数
    NSString *clsName = @"";
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        clsName = @"GDTSDKConfig";
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"BUAdSDKManager";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryConfigManager";
    }
    
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        // 广点通SDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(registerAppId:) withObject:supplier.mediaid];
        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        // 穿山甲SDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(setAppID:) withObject:supplier.mediaid];//
        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        // MercurySDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(setAppID:mediaKey:) withObject:supplier.mediaid withObject:supplier.mediakey];
        });
    }
    
    // 如果执行了打底渠道 则执行此方法
    if ([supplier.sdktag isEqualToString:@"bottom_default"]) {
        [self advSupplierLoadDefaultSuppluer:supplier];
    }

    // 加载渠道
    if ([_baseDelegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
//        NSLog(@"xxxxerror: %@   clsName: %@", error, clsName);
        [_baseDelegate advanceBaseAdapterLoadSuppluer:supplier error:error];
    }
}

// MARK: ======================= get =======================
- (AdvSupplierManager *)mgr {
    if (!_mgr) {
        _mgr = [AdvSupplierManager manager];
        _mgr.delegate = self;
        _baseDelegate = self;
    }
    return _mgr;
}

@end
