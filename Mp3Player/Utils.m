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
    return songs;
}

+ (NSMutableDictionary*)getSongsDict{
    return songsDict;
}


+ (NSInteger)getPlayIndex{
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

+ (NSString *)getPlaySongName{
    return [Utils getAllSongs][[Utils getPlayIndex]];
}


+ (NSURL *) rootPath{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return [documentDirectories firstObject];
}

+(NSURL*)getFilePath:(NSString*)filePath{
    NSURL *path = [[self rootPath] URLByAppendingPathComponent:filePath];
    NSLog(@"File path %@" , path);
    return path;
}

+ (NSData*)readFile:(NSString*) filePath{
    NSLog(@"Reading file %@", filePath );
    return [NSData dataWithContentsOfURL:[self getFilePath:filePath]];
}

//http://stackoverflow.com/questions/22952929/any-other-ways-to-access-documents-directory-on-idevice-locked-state
+ (NSURL *)saveFile:(NSData *)fileDate filePath:(NSString *)filePath  {
    NSURL *savePath = [[self rootPath] URLByAppendingPathComponent:filePath];
    NSLog(@"Save file path %@" , savePath );
    NSError *error;
    [fileDate writeToURL:savePath options:NSDataWritingFileProtectionNone error:&error];
    if(error){
        NSLog(@"PlayMP3Prepare error %@, %@", error, [error userInfo]);
    }
    
    return savePath;
}

@end
