//
//  CustomListFeedExpressViewController.m
//  AdvanceSDKDev
//
//  Created by 程立卿 on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CustomListFeedExpressViewController.h"
#import "CellBuilder.h"
#import "BYExamCellModel.h"

#import "DemoUtils.h"
#import "AdvanceSDK.h"
#import <MercurySDK/MercurySDK.h>
#import <GDTNativeExpressAd.h>
#import <GDTNativeExpressAdView.h>
#import <BUAdSDK/BUAdSDK.h>

@interface CustomListFeedExpressViewController () <UITableViewDelegate, UITableViewDataSource, AdvanceBaseAdspotDelegate, MercuryNativeExpressAdDelegete, GDTNativeExpressAdDelegete, BUNativeExpressAdViewDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) AdvanceBaseAdspot *adspot;
@property (nonatomic, strong) NSMutableArray *dataArrM;

@property (nonatomic, strong) GDTNativeExpressAd *gdt_ad;
@property (nonatomic, strong) BUNativeExpressAdManager *csj_ad;
@property (nonatomic, strong) MercuryNativeExpressAd *mercury_ad;

@end

@implementation CustomListFeedExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"信息流";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"splitnativeexpresscell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nativeexpresscell"];
    [_tableView registerClass:[ExamTableViewCell class] forCellReuseIdentifier:@"ExamTableViewCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    
    [self loadBtnAction:nil];
}

- (void)loadBtnAction:(id)sender {
    _dataArrM = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
    _adspot = [[AdvanceNativeExpress alloc] initWithMediaId:self.mediaId adspotId:self.adspotId viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 300)];
    
    _adspot.supplierDelegate = self;
    [_adspot setDefaultSdkSupplierWithMediaId:@"100255"
                                          adspotid:@"10002698"
                                          mediakey:@"757d5119466abe3d771a211cc1278df7"
                                            sdkTag:SDK_TAG_MERCURY];
    [_adspot loadAd];
}

// MARK: ======================= AdvanceBaseAdspotDelegate =======================
/// 加载渠道广告，将会返回渠道所需参数
/// @param sdkTag 渠道Tag
/// @param params 渠道参数
- (void)advanceBaseAdspotWithSdkTag:(NSString *)sdkTag params:(NSDictionary *)params {
    // 根据渠道id自定义初始化
    
    int adCount = 1;
    if (_adspot && _adspot.currentSdkSupplier.adCount > 0) {
        adCount = _adspot.currentSdkSupplier.adCount;
    }
    CGSize adSize = CGSizeMake(self.view.bounds.size.width, 300);
    
    if ([sdkTag isEqualToString:@"gdt"]) {
        _gdt_ad = [[GDTNativeExpressAd alloc] initWithAppId:[params objectForKey:@"mediaid"]
                                                placementId:[params objectForKey:@"adspotid"]
                                                     adSize:adSize];
        _gdt_ad.delegate = self;
        [_gdt_ad loadAd:adCount];
    } else if ([sdkTag isEqualToString:@"csj"]) {
        BUAdSlot *slot = [[BUAdSlot alloc] init];
        slot.ID = [params objectForKey:@"adspotid"];
        slot.isSupportDeepLink = YES;
        slot.AdType = BUAdSlotAdTypeFeed;
        slot.position = BUAdSlotPositionFeed;
        slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
        _csj_ad = [[BUNativeExpressAdManager alloc] initWithSlot:slot adSize:adSize];
        _csj_ad.delegate = self;
        [_csj_ad loadAd:adCount];
    } else if ([sdkTag isEqualToString:@"bayes"]) {
        _mercury_ad = [[MercuryNativeExpressAd alloc] initAdWithAdspotId:_adspot.currentSdkSupplier.adspotid];
        _mercury_ad.delegate = self;
        _mercury_ad.videoMuted = YES;
        _mercury_ad.videoPlayPolicy = MercuryVideoAutoPlayPolicyWIFI;
        _mercury_ad.renderSize = adSize;
        [_mercury_ad loadAdWithCount:adCount];
    }
}

// MARK: ======================= MercuryNativeExpressAdDelegete =======================
/// 拉取原生模板广告成功 | (注意: nativeExpressAdView在此方法执行结束不被强引用，nativeExpressAd中的对象会被自动释放)
- (void)mercury_nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(nonnull NSArray<MercuryNativeExpressAdView *> *)views {
    if (views == nil || views.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
        [self.adspot selectSdkSupplierWithError:nil];
    } else {
        for (UIView *view in views) {
            if ([view isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
                ((MercuryNativeExpressAdView *)view).controller = self;
                [((MercuryNativeExpressAdView *)view) render];
                [_dataArrM insertObject:view atIndex:1];
            }
        }
        [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
        [self.tableView reloadData];
        NSLog(@"拉取数据成功 ");
    }
}

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoadWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    [self.adspot selectSdkSupplierWithError:error];
    NSLog(@"拉取原生模板广告失败");
}

/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView {
    
}

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    [self.adspot selectSdkSupplierWithError:nil];
    NSLog(@"原生模板广告渲染失败");
}

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    NSLog(@"原生模板广告曝光回调");
}

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    NSLog(@"原生模板广告点击回调");
}

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView {
    
}

// MARK: ======================= GDTNativeExpressAdDelegete =======================
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    if (views == nil || views.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
        [self.adspot selectSdkSupplierWithError:nil];
    } else {
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
        if ([self.adspot.currentSdkSupplier.sdkTag isEqualToString:@"gdt"]) {
            for (GDTNativeExpressAdView *view in views) {
                view.controller = self;
            }
        } else if ([self.adspot.currentSdkSupplier.sdkTag isEqualToString:@"csj"]) {
            [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
            for (BUNativeExpressAdView *view in views) {
                view.rootViewController = self;
            }
        }
    }
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _gdt_ad = nil;
    _csj_ad = nil;
    [_adspot selectSdkSupplierWithError:error];
}

/**
 * 渲染原生模板广告失败
 */
- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _gdt_ad = nil;
    [_adspot selectSdkSupplierWithError:[NSError errorWithDomain:@"" code:10000 userInfo:@{@"msg": @"渲染原生模板广告失败"}]];
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked];
}

- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped];
}

// MARK: ======================= BUNativeExpressAdViewDelegate =======================
// 这两个方法与广点通的相同，具体处理见 GDTNativeExpressAdDelegete
//- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error;
//- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    [_adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _csj_ad = nil;
    [_adspot selectSdkSupplierWithError:error];
}

- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped];
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked];
}

// MARK: ======================= UITableViewDelegate, UITableViewDataSource =======================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArrM.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_dataArrM[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        return ((BYExamCellModelElement *)_dataArrM[indexPath.row]).cellh;
    } else {
        return ((UIView *)_dataArrM[indexPath.row]).bounds.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([_dataArrM[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ExamTableViewCell"];
        ((ExamTableViewCell *)cell).item = _dataArrM[indexPath.row];
        return cell;
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"nativeexpresscell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
        if ([subView superview]) {
            [subView removeFromSuperview];
        }
        UIView *view = _dataArrM[indexPath.row];
        view.tag = 1000;
        [cell.contentView addSubview:view];
        cell.accessibilityIdentifier = @"nativeTemp_ad";
        return cell;
    }
}

@end

