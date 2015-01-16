//
//  Player.m
//  Mp3Player
//
//  Created by FHDone on 15/1/16.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//
#import "Player.h"
#import <AVFoundation/AVFoundation.h>
#import "Utils.h"


static AVAudioPlayer *player;
static BOOL playing;
static NSInteger downloadSongIndex;
static NSURLSession *mp3DownloadSession;

@interface Player()

@end


@implementation Player


+ (void)playMp3 {
    if ([player play])
    {
        playing = YES;
        [self playStateChanged:@"Pause"];
    }
    else
    {
        NSLog(@"Could not play %@\n", player.url);
    }
}

+ (void)pauseMp3 {
    playing = NO;
    [player pause];
    [self playStateChanged:@"Play"];
}

+ (void)playOrPause {
    if (player.playing == YES){
        [self pauseMp3];
    }
    else{
        [self playMp3];
    }
}

+(void)playSongFromName:(NSString*)songName{
    NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:songName ofType:nil];
    if( musicFilePath){
        [self playSongFromDisk:musicFilePath];
    }
    else{
        NSString* url = [[Utils getSongsDict]objectForKey:songName];
        if ( url ){
            [self playSongFromUrl:url];
        }
        else{
            [self playSongFromName: [Utils getAllSongs][[Utils getNextIndex]] ];
        }
    }
}


+(void)playSongFromDisk:(NSString*)musicFilePath{
    NSURL * musicURL= [[NSURL alloc] initFileURLWithPath: musicFilePath ];
    //NSURL  *musicURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/逍遥叹.mp3",  [[NSBundle mainBundle]  resourcePath]]];
    
    NSError  *error;
    player  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
    if(error){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    player.delegate = (id<AVAudioPlayerDelegate>)self;
    [self playMp3];
    //[thePlayer setVolume:10];
    //[player setNumberOfLoops:0];
}


+(void)playSongFromUrl:(NSString*) url{
    downloadSongIndex = [Utils playIndex];
    NSLog(@"start download");
    NSMutableURLRequest *request = [ NSMutableURLRequest requestWithURL: [NSURL URLWithString:url] ];
    if(!mp3DownloadSession){
        NSURLSessionConfiguration *sessionConfig;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:MP3_FETCH];
            [request setTimeoutInterval:15];
            [request setAllowsCellularAccess:NO];
        }
        else {
            sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:MP3_FETCH];
            sessionConfig.allowsCellularAccess = NO;
            sessionConfig.timeoutIntervalForRequest = 15;
        }
        mp3DownloadSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:(id<NSURLSessionDownloadDelegate>)self  delegateQueue:nil ];
    }
    
    NSURLSessionDownloadTask *task = [mp3DownloadSession downloadTaskWithRequest:request];
    task.taskDescription = MP3_FETCH;
    [task resume];

}


#pragma mark - Notification
+(void)playStateChanged:(NSString*)playState{
    NSDictionary *stateDict = [NSDictionary dictionaryWithObjectsAndKeys:playState,@"State",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerStateChange object:self userInfo:stateDict];
}


#pragma mark - AVAudioPlayer delegate
+ (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying");
    [self playSongFromName: [Utils getAllSongs][[Utils getNextIndex]]  ];
}

+ (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"audioPlayerBeginInterruption");
    [self playStateChanged:@"Play"];
}

+ (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    NSLog(@"audioPlayerEndInterruption");
    [self playMp3];
    [self playStateChanged:@"Pause"];
}

#pragma mark - NSURLSessionDownloadDelegate
+ (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;
{
    if ([downloadTask.taskDescription isEqualToString:MP3_FETCH]) {
        NSLog(@"download completed");
        if( downloadSongIndex == [Utils playIndex]){
            NSData *d = [NSData dataWithContentsOfURL:location];
            NSLog( @"%ld", [d length]);
            NSError  *error;
            player  = [[AVAudioPlayer alloc] initWithData:d error:&error];
            player.delegate = (id<AVAudioPlayerDelegate>)self;
            //[self.loadingSpinner stopAnimating];
            [self playMp3];
        }
    }
}

+ (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    if(error){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [self playSongFromName: [Utils getAllSongs][[Utils getNextIndex]] ];
    }
}



@end