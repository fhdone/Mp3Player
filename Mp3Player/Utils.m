//
//  Utils.m
//  Demo
//
//  Created by FHDone on 14/12/5.
//  Copyright (c) 2014年 com.fhdone. All rights reserved.
//

#import "Utils.h"


static NSMutableArray *songs;
static NSInteger playIndex;

@interface Utils ()



@end


@implementation Utils


+ (NSMutableArray *)getAllSongs{
    if(! songs){
        songs =  [NSMutableArray arrayWithObjects:@"骊歌",@"阿诗玛",@"逍遥叹", nil];
    }
    return songs;
}


+ (NSInteger)playIndex{
    return playIndex;
}


+ (void)setPlayIndex:(NSInteger) index{
    playIndex = index;
}


+ (NSInteger)getNextIndex{
    playIndex ++;
    if( playIndex  >= [songs count] ){
        playIndex = 0;
    }
    return playIndex;
}

+ (NSInteger)getPerviousIndex{
    playIndex --;
    if( playIndex  < 0 ){
        playIndex = [songs count]-1;
    }
    return playIndex;
}



@end
