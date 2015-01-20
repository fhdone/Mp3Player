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

@interface PlayerViewController ()



@end

@implementation PlayerViewController



- (void)viewDidLoad {
    [super viewDidLoad];
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
    //NSLog(@"%@",notification.userInfo[@"State"]);
    [self.playButton setTitle:notification.userInfo[@"State"] forState:UIControlStateNormal];
    self.playingTitle.text = [Player playingTitle];
    self.playArtist.text = [Player playingArtist];
    self.playingImg.image = [Player playingImg];
    //http://stackoverflow.com/questions/5408234/how-to-force-a-view-to-render-itself
    [CATransaction flush];
    //[self.playingImg sizeToFit];
}


- (void)initPlayer {
    [Player playSongFromName: [Utils getPlaySongName]] ;
}




@end
