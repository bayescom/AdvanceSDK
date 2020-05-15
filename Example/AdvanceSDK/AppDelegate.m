//
//  AppDelegate.m
//  AdvanceSDK
//
//  Created by Cheng455153666 on 02/27/2020.
//  Copyright (c) 2020 Cheng455153666. All rights reserved.
//

#import "AppDelegate.h"

#import <AdvanceSDK/AdvanceSDK.h>
#import "ViewController.h"

#import <MercurySDK/MercurySDK.h>
#import <BUAdSDK/BUAdSDK.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    [BUAdSDKManager setAppID:@"5000546"];
    [MercuryConfigManager setAppID:@"100255"
                          mediaKey:@"757d5119466abe3d771a211cc1278df7"];
    
    return YES;
}

@end
