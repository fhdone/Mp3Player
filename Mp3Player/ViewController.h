//
//  ViewController.h
//  Mp3Player
//
//  Created by FHDone on 15/1/12.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

    @property (weak, nonatomic) IBOutlet UIButton *playButton;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
    @property(strong,nonatomic) NSString *songName;

@end
