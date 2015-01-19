//
//  Player.m
//  Mp3Player
//
//  Created by FHDone on 15/1/16.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//
#import "Player.h"
#import "Utils.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>


#define PLAY_STRING	@">"
#define PAUSE_STRING	@"||"

static AVAudioPlayer *player;
static BOOL playing;
static NSInteger downloadSongIndex;
static NSURLSession *mp3DownloadSession;
static NSString *playingArtist;
static NSString *playingTitle;
static UIImage *playingImg;

@interface Player()

@end


@implementation Player
+ (void)playMp3 {
    if ([player play])
    {
        playing = YES;
        [self playStateChanged:PAUSE_STRING];
    }
    else
    {
        NSLog(@"Could not play %@\n", player.url);
    }
}

+ (void)pauseMp3 {
    playing = NO;
    [player pause];
    [self playStateChanged:PLAY_STRING];
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
            [self playSongFromUrl:url fileName:songName];
        }
        else{
            [self playSongFromName: [Utils getAllSongs][[Utils getNextIndex]] ];
        }
    }
}

+(void)playMP3Prepare:(NSURL*)musicURL{
    NSError  *error;
    player  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
    if(error){
        NSLog(@"PlayMP3Prepare error %@, %@", error, [error userInfo]);
    }
    player.delegate = (id<AVAudioPlayerDelegate>)self;
    [self metadataWithFileURL:musicURL playerDuring:player.duration];
    
//    UIBackgroundTaskIdentifier bgTaskId = 0;
//    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    [self playMp3];
//    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
//    if (newTaskId != UIBackgroundTaskInvalid && bgTaskId != UIBackgroundTaskInvalid)
//        [[UIApplication sharedApplication] endBackgroundTask: bgTaskId];
//    
//    bgTaskId = newTaskId;
}


+(void)playSongFromDisk:(NSString*)musicFilePath{
    NSURL * musicURL= [[NSURL alloc] initFileURLWithPath: musicFilePath ];
    [self playMP3Prepare:musicURL];
    //[thePlayer setVolume:10];
    //[player setNumberOfLoops:0];
}


+(void)playSongFromUrl:(NSString*) url fileName:(NSString*)fileName {
    NSData *data = [Utils readFile:fileName];
    if(data){
        [self playMP3Prepare:[Utils getFilePath:fileName]];
    }
    else{
        downloadSongIndex = [Utils getPlayIndex];
        NSLog(@"start download %@" , fileName);
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
    [self playStateChanged:PLAY_STRING];
}

+ (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    NSLog(@"audioPlayerEndInterruption");
    [self playMp3];
    [self playStateChanged:PAUSE_STRING];
}

#pragma mark - NSURLSessionDownloadDelegate
+ (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;
{
    if ([downloadTask.taskDescription isEqualToString:MP3_FETCH]) {
        NSLog(@"download completed %@" , location);
        if( downloadSongIndex == [Utils getPlayIndex]){
            NSData *d = [NSData dataWithContentsOfURL:location];
            NSURL *filePath = [Utils saveFile:d filePath:[Utils getPlaySongName] ];
            [self playMP3Prepare:filePath];
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


//http://stackoverflow.com/questions/14030746/ios-avfoundation-how-do-i-fetch-artwork-from-an-mp3-file
+ (void)metadataWithFileURL:(NSURL*)fileURL playerDuring:(double)playerDuring {
    NSMutableDictionary *mediaInfo = [[NSMutableDictionary alloc]init];
    playingTitle = nil;
    playingArtist = nil;
    playingImg = nil;
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSArray *titles = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
    NSArray *artists = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtist keySpace:AVMetadataKeySpaceCommon];
    NSArray *albumNames = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyAlbumName keySpace:AVMetadataKeySpaceCommon];
    if( [titles count] ){
        AVMetadataItem *title = [titles objectAtIndex:0];
        playingTitle = (NSString*)title.value;
        [mediaInfo setObject:[title.value copyWithZone:nil]  forKey:MPMediaItemPropertyTitle];
    }
    else{
        NSString *songTitle = [Utils getPlaySongName];
        playingTitle = songTitle;
        [mediaInfo setObject:songTitle forKey:MPMediaItemPropertyTitle];
    }
    if( [artists count] ){
        AVMetadataItem *artist = [artists objectAtIndex:0];
        playingArtist = (NSString*)artist.value;;
        [mediaInfo setObject:[artist.value copyWithZone:nil]  forKey:MPMediaItemPropertyArtist];
    }
    if( [albumNames count] ){
        AVMetadataItem *albumName = [albumNames objectAtIndex:0];
        [mediaInfo setObject:[albumName.value copyWithZone:nil]  forKey:MPMediaItemPropertyAlbumTitle];
    }
    
    NSArray *keys = [NSArray arrayWithObjects:@"commonMetadata", nil];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                           withKey:AVMetadataCommonKeyArtwork
                                                          keySpace:AVMetadataKeySpaceCommon];
        UIImage *img = nil;
        for (AVMetadataItem *item in artworks) {
            NSData *newImage = [item.value copyWithZone:nil];
            img = [UIImage imageWithData:newImage];
            playingImg = img;
            MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:img ];
            [mediaInfo setObject: mArt forKey:MPMediaItemPropertyArtwork ];
            break;
        }
    }];
    [mediaInfo setObject:[NSNumber numberWithDouble:playerDuring ] forKey:MPMediaItemPropertyPlaybackDuration];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    
//    NSDictionary *stateDict = [NSDictionary dictionaryWithObjectsAndKeys:playState,@"State",nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerStateChange object:self userInfo:stateDict];
    
}


+ (NSString *) playingArtist{
    return playingArtist;
}
+ (NSString *) playingTitle{
    return playingTitle;
}
+ (UIImage *) playingImg{
    return playingImg;
}
@end




