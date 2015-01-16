//
//  AppDelegate.m
//  Mp3Player
//
//  Created by FHDone on 15/1/12.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "Player.h"
#import "Utils.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"didFinishLaunchingWithOptions");
    // Override point for customization after application launch.
    
    //http://stackoverflow.com/questions/26996269/how-to-use-an-event-listener-to-detect-headset-plug-out-in-swift
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    //    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self becomeFirstResponder];
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    UIBackgroundTaskIdentifier oldTakId = 0;
    if(newTaskId != UIBackgroundTaskInvalid && oldTakId != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:oldTakId];
    }
    oldTakId = newTaskId;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [self resignFirstResponder];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}


#pragma mark - AVAudioPlayer controller
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


-(void)handleRouteChange:(NSNotification *)notif
{
    NSDictionary *dict = notif.userInfo;
    AVAudioSessionRouteDescription *routeDesc = dict[AVAudioSessionRouteChangePreviousRouteKey];
    AVAudioSessionPortDescription *prevPort = [routeDesc.outputs objectAtIndex:0];
    if ([prevPort.portType isEqualToString:AVAudioSessionPortHeadphones]) {
        [Player pauseMp3];
    }
}


- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [Player playMp3];
                break;
            case UIEventSubtypeRemoteControlPause:
                [Player pauseMp3];
                break;
//            case UIEventSubtypeRemoteControlStop:
//                [player stop];
//                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [Player playOrPause];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [Player playSongFromName: [Utils getAllSongs][[Utils getPerviousIndex]] ];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [Player playSongFromName: [Utils getAllSongs][[Utils getNextIndex]] ];
                break;
            default:
                break;
        }
    }
}

@end
