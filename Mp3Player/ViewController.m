//
//  ViewController.m
//  Mp3Player
//
//  Created by FHDone on 15/1/12.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Utils.h"

static AVAudioPlayer *player;

@interface ViewController ()  <AVAudioPlayerDelegate>

    @property (weak, nonatomic) IBOutlet UIButton *playButton;
    @property (assign,nonatomic) BOOL playing;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initPlayer];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)playSongFromName:(NSString*)songName{
    NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:songName ofType:@"mp3"];
    NSURL * musicURL= [[NSURL alloc] initFileURLWithPath: musicFilePath ];
    //NSURL  *musicURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/逍遥叹.mp3",  [[NSBundle mainBundle]  resourcePath]]];
    
    NSError  *error;
    player  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
    player.delegate = self;

//        [thePlayer setVolume:10];
//        [player setNumberOfLoops:0];
        [self playMp3];
 
    
}

-(void)play2{
    NSString  *MP3_URL = @"http://yinyueshiting.baidu.com/data2/music/123980751/20892631421042461128.mp3?xcode=8bdd01004be3ddf9abb4d42c7f9a3a406e80cfcc6aeb83a6";
    
    NSURLRequest *request = [ NSURLRequest requestWithURL: [NSURL URLWithString:MP3_URL] ];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
    //    sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT; // want to be a good background citizen!
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                        if (error) {
                                                            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
                                                            NSLog(@"MP3 background fetch failed: %@", error.localizedDescription);
                                                        } else {
                                                            NSLog(@"download completed");
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                NSError  *error;
                                                                player  = [[AVAudioPlayer alloc] initWithContentsOfURL:localFile error:&error];
                                                                player.delegate = self;
//                                                                [player setNumberOfLoops:0];
                                                                [self playMp3];
                                                            });
                                                        }
                                                    }];
    [task resume];
}


- (IBAction)playMusic:(UIButton *)sender {
    [self playOrPause];
    
}


#pragma mark - Controller

- (void)initPlayer {
    //http://stackoverflow.com/questions/26996269/how-to-use-an-event-listener-to-detect-headset-plug-out-in-swift
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    //    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self becomeFirstResponder];
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    [self playSongFromName:self.songName];
    [self playMp3];

    
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    UIBackgroundTaskIdentifier oldTakId = 0;
    if(newTaskId != UIBackgroundTaskInvalid && oldTakId != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:oldTakId];
    }
    oldTakId = newTaskId;
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)playMp3 {
    if ([player play])
    {
        self.playing = YES;
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else
    {
        NSLog(@"Could not play %@\n", player.url);
    }
}

- (void)pauseMp3 {
    self.playing = NO;
    [player pause];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)playOrPause {
    if (player.playing == YES){
        [self pauseMp3];
    }
    else{
        [self playMp3];
    }
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [player play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [player pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                [player stop];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playOrPause];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playSongFromName: [Utils getAllSongs][[Utils getPerviousIndex]] ];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self playSongFromName: [Utils getAllSongs][[Utils getNextIndex]] ];
                break;
            default:
                break;
        }
    }
}


-(void)handleRouteChange:(NSNotification *)notif
{
    NSDictionary *dict = notif.userInfo;
    AVAudioSessionRouteDescription *routeDesc = dict[AVAudioSessionRouteChangePreviousRouteKey];
    AVAudioSessionPortDescription *prevPort = [routeDesc.outputs objectAtIndex:0];
    if ([prevPort.portType isEqualToString:AVAudioSessionPortHeadphones]) {
        [self pauseMp3];
    }
}



#pragma mark - AVAudioPlayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying");
//    [self play2];
    [self playSongFromName: [Utils getAllSongs][[Utils getNextIndex]]  ];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    // perform any interruption handling here
//    printf("(apbi) Interruption Detected\n");
//    [[NSUserDefaults standardUserDefaults] setFloat:[self.thePlayer currentTime] forKey:@"Interruption"];
    NSLog(@"audioPlayerBeginInterruption");
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    // resume playback at the end of the interruption
//    printf("(apei) Interruption ended\n");
    NSLog(@"audioPlayerEndInterruption");
    [self playOrPause];
//    [player play];
//    [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    
    // remove the interruption key. it won't be needed
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Interruption"];
}
@end
