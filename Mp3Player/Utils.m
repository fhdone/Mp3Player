//
//  Utils.m
//  Demo
//
//  Created by FHDone on 14/12/5.
//  Copyright (c) 2014年 com.fhdone. All rights reserved.
//

#import "Utils.h"
#import "INIParser.h"

static NSMutableArray *songs;
static NSMutableDictionary *songsDict;
static NSInteger playIndex;

@interface Utils ()



@end


@implementation Utils


+ (NSMutableArray *)getAllSongs{
    if(! songs){
//        songs =  [NSMutableArray arrayWithObjects:@"骊歌",@"阿诗玛",@"逍遥叹", nil];
        songs = [[NSMutableArray alloc]init];
        
        NSString *resPath = [[NSBundle mainBundle] resourcePath];
        NSError *error = nil;
        NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resPath error:&error];
        if (!error)
        {
            for (NSString * filename in filenames)
            {
                NSString *extension = [filename pathExtension];
                if ( [extension caseInsensitiveCompare:@"mp3"] == 0)
                {
//                    NSLog(@"%@", filename);
                    [songs addObject:filename];
                }
            }
            NSArray *arr = [songs sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            songs = [NSMutableArray arrayWithArray:arr];
        }
        
        songsDict = [INIParser iniParse:@"songs"];
        [songs addObjectsFromArray:[songsDict allKeys] ];
    }
    
    //    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    //    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    //    NSDirectoryEnumerator *dirEnum =
    //    [localFileManager enumeratorAtPath:docsDir];
    //
    //    NSString *file;
    //    while ((file = [dirEnum nextObject])) {
    //        if ([[file pathExtension] isEqualToString: @"doc"]) {
    //            // process the document
    //            [self scanDocument: [docsDir stringByAppendingPathComponent:file]];
    //        }
    //    }
    
    
    return songs;
}

+ (NSMutableDictionary*)getSongsDict{
    return songsDict;
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
