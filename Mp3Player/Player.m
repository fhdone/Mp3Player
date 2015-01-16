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
//    [self.loadingSpinner startAnimating];
//    NSURLRequest *request = [ NSURLRequest requestWithURL: [NSURL URLWithString:url] ];
//    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    if(!mp3DownloadSession){
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:MP3_FETCH];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = 15;
        mp3DownloadSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:(id<NSURLSessionDownloadDelegate>)self  delegateQueue:nil ];
    }
    NSLog(@"start download");
    NSURLSessionDownloadTask *task = [mp3DownloadSession downloadTaskWithURL:[NSURL URLWithString:url] ];
    task.taskDescription = MP3_FETCH;
    [task resume];
    
//    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
//                                                    completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
//                                                        if (error) {
//                                                            [self playStateChanged:@"Play"];
//                                                            NSLog(@"MP3 background fetch failed: %@", error.localizedDescription);
//                                                        } else {
//                                                            NSLog(@"download completed");
//                                                            dispatch_async(dispatch_get_main_queue(), ^{
//                                                                if( index == [Utils playIndex]){
//                                                                    NSError  *error;
//                                                                    player  = [[AVAudioPlayer alloc] initWithContentsOfURL:localFile error:&error];
//                                                                    player.delegate = (id<AVAudioPlayerDelegate>)self;
//                                                                    //[self.loadingSpinner stopAnimating];
//                                                                    [self playMp3];
//                                                                }
//                                                            });
//                                                        }
//                                                    }];
//    [task resume];
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



@end