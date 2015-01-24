//  ViewController.m
//  Mp3Player
//
//  Created by FHDone on 15/1/12.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Utils.h"
#import "Player.h"
#import "NSString+TimeToString.h"

@interface PlayerViewController ()

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIImageView *playingImg;
@property (weak, nonatomic) IBOutlet UILabel *playingTitle;
@property (weak, nonatomic) IBOutlet UILabel *playArtist;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UILabel *trackCurrentPlaybackTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackLengthLabel;
@property BOOL panningProgress;
//    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (assign,nonatomic) NSInteger songIndex;

@end

@implementation PlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
//    [CATransaction setDisableActions:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChange:) name:PlayerStateChange object:nil];
    [self initPlayer];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PlayerStateChange object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)playMusic:(UIButton *)sender {
    [Player playOrPause];
    
}

- (IBAction)playNext:(UIButton *)sender {
    [Player playSongFromName: [Utils getAllSongs][[Utils getNextIndex]]  ];
}

- (IBAction)playPervious:(UIButton *)sender {
    [Player playSongFromName: [Utils getAllSongs][[Utils getPerviousIndex]]  ];
}

#pragma mark - Controller

-(void) playerStateChange:(NSNotification *) notification
{
    [self.playButton setTitle:notification.userInfo[@"State"] forState:UIControlStateNormal];
    self.playingTitle.text = [Player playingTitle];
    self.playArtist.text = [Player playingArtist];
    self.playingImg.image = [Player playingImg];
    self.playSlider.value = [[Player player]currentTime];
    self.playSlider.maximumValue = [Player playingDuring];
    self.trackLengthLabel.text = [NSString stringFromTime:[Player playingDuring]];
    //http://stackoverflow.com/questions/5408234/how-to-force-a-view-to-render-itself
    [CATransaction flush];
}


- (void)initPlayer {
    [Player playSongFromName: [Utils getPlaySongName]] ;
    
    [self.playSlider setThumbImage:[UIImage imageNamed:@"Images/playing.png"] forState:UIControlStateNormal ];
    self.playSlider.thumbTintColor = [UIColor whiteColor];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timedJob) userInfo:nil repeats:YES];
}

#pragma mark - Play slider
- (void)timedJob {
    if (!self.panningProgress) {
        self.playSlider.value = [[Player player]currentTime];
        self.trackCurrentPlaybackTimeLabel.text = [NSString stringFromTime: [[Player player]currentTime ]];
    }
}
- (IBAction)progressChanged:(UISlider *)sender {
    self.panningProgress = YES;
    self.trackCurrentPlaybackTimeLabel.text = [NSString stringFromTime: sender.value];
}

- (IBAction)progressEnd:(UISlider *)sender {
    self.panningProgress = NO;
    [[Player player] setCurrentTime: self.playSlider.value];
}

@end
