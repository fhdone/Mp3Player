//
//  Player.h
//  Mp3Player
//
//  Created by FHDone on 15/1/16.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PlayerStateChange @"PlayerStateChange"
#define MP3_FETCH @"MP3_FETCH"

@interface Player : NSObject


+ (void)playMp3;

+ (void)pauseMp3;

+ (void)playOrPause;

+(void)playSongFromName:(NSString*)songName;

@end