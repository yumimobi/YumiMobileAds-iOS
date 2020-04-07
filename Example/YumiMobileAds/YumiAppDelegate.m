//
//  YumiAppDelegate.m
//  YumiMobileAds
//
//  Created by wzy2010416033@163.com on 06/05/2019.
//  Copyright (c) 2019 wzy2010416033@163.com. All rights reserved.
//

#import "YumiAppDelegate.h"
#import "MoPub.h"
@import AppCenter;
@import AppCenterAnalytics;
@import AppCenterCrashes;

@implementation YumiAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // init mopub
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"637cd2fa5d9e43b9a2538a219a693ee6"];

    sdkConfig.loggingLevel = MPBLogLevelInfo;
    [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
        NSLog(@"SDK initialization complete");
    }];
    
    // init app center
    [MSAppCenter start:@"890e833e-b3a3-41e9-a723-e0b0df97c895" withServices:@[
                                                                              [MSAnalytics class],
                                                                              [MSCrashes class]
                                                                              ]];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
