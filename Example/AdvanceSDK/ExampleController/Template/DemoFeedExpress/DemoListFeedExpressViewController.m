//
//  DemoListFeedExpressViewController.m
//  Example
//
//  Created by 程立卿 on 2019/11/21.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoListFeedExpressViewController.h"
#import "CellBuilder.h"
#import "BYExamCellModel.h"

#import "DemoUtils.h"
#import "AdvanceSDK.h"

@interface DemoListFeedExpressViewController () <UITableViewDelegate, UITableViewDataSource, AdvanceNativeExpressDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property(strong,nonatomic) AdvanceNativeExpress *advanceFeed;
@property (nonatomic, strong) NSMutableArray *dataArrM;

@end

@implementation DemoListFeedExpressViewController

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
    _advanceFeed = [[AdvanceNativeExpress alloc] initWithMediaId:self.mediaId adspotId:self.adspotId viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 300)];
    
    _advanceFeed.delegate = self;
    [_advanceFeed setDefaultSdkSupplierWithMediaId:@"100255"
                                          adspotid:@"10002698"
                                          mediakey:@"757d5119466abe3d771a211cc1278df7"
                                            sdkTag:SDK_TAG_MERCURY];
    [_advanceFeed loadAd];
}

// MARK: ======================= AdvanceNativeExpressDelegate =======================
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(NSArray<UIView *> *)views {
    NSLog(@"拉取数据成功 ");
    for (NSInteger i=0; i<views.count;i++) {
        if ([views[i] isKindOfClass:NSClassFromString(@"BUNativeExpressFeedVideoAdView")]) {
            [views[i] performSelector:@selector(setRootViewController:) withObject:self];
            [views[i] performSelector:@selector(render)];
        } else if ([views[i] isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
            [views[i] performSelector:@selector(render)];
            [views[i] performSelector:@selector(setController:) withObject:self];
        } else if ([views[i] isKindOfClass:NSClassFromString(@"GDTNativeExpressAdView")]) {
            [views[i] performSelector:@selector(render)];
            [views[i] performSelector:@selector(setController:) withObject:self];
        }
        [_dataArrM insertObject:views[i] atIndex:1];
    }
    [self.tableView reloadData];
}

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(UIView *)adView {
    NSLog(@"广告曝光");
}

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(UIView *)adView {
    NSLog(@"广告点击");
}

/// 广告渲染成功
- (void)advanceNativeExpressOnAdRenderSuccess:(UIView *)adView {
    [self.tableView reloadData];
}

/// 广告渲染失败
- (void)advanceNativeExpressOnAdRenderFail:(UIView *)adView {
    NSLog(@"广告渲染失败");
}

/// 广告被关闭
- (void)advanceNativeExpressOnAdClosed:(UIView *)adView {
    //需要从tableview中删除
    NSLog(@"广告关闭");
    [_dataArrM removeObject: adView];
    [adView removeFromSuperview];
    [self.tableView reloadData];
}

/// 广告数据拉取失败
- (void)advanceNativeExpressOnAdFailedWithAdapterId:(nullable NSString *)adapterId error:(nullable NSError *)error {
    NSLog(@"广告拉取失败");
}

// MARK: ======================= UITableViewDelegate, UITableViewDataSource =======================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _expressAdViews.count*2;
//    return 2;
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


