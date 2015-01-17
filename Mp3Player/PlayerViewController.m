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

-(void)awakeFromNib{
    [super awakeFromNib];
//    [[NSNotificationCenter defaultCenter] addObserverForName:PlayerStateChange
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification *note) {
//                                                      [self.playButton setTitle:note.userInfo[@"State"] forState:UIControlStateNormal];
//                                                  }];
//    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChange:) name:PlayerStateChange object:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPlayer];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:PlayerStateChange object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)playMusic:(UIButton *)sender {
    [Player playOrPause];
    
}


#pragma mark - Controller

-(void) playerStateChange:(NSNotification *) notification
{
//    NSLog(@"%@",notification.userInfo[@"State"]);
    [self.playButton setTitle:notification.userInfo[@"State"] forState:UIControlStateNormal];
}


- (void)initPlayer {
    [Player playSongFromName: [Utils getPlaySongName]] ;
}




@end
