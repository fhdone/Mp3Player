//
//  Utils.h
//  Demo
//
//  Created by FHDone on 14/12/5.
//  Copyright (c) 2014年 com.fhdone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSMutableArray *)getAllSongs;
+ (NSMutableDictionary *)getSongsDict;

 

+ (NSInteger)playIndex;
+ (void)setPlayIndex:(NSInteger) index;
+ (NSInteger)getNextIndex;
+ (NSInteger)getPerviousIndex;

@end
