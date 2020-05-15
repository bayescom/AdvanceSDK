//
//  AdvanceNativeExpress.h
//  AdvanceSDKDev
//
//  Created by 程立卿 on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceBaseAdspot.h"
#import "AdvanceSdkConfig.h"
#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceNativeExpress : AdvanceBaseAdspot
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) CGSize adSize;
@property(nonatomic,strong,nullable) NSMutableDictionary * extraSettings;

- (instancetype)initWithMediaId:(NSString *)mediaid
                       adspotId:(NSString *)adspotid
                 viewController:(UIViewController *)viewController
                         adSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
