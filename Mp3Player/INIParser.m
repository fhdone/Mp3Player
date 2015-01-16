//
//  INIParser.m
//  Mp3Player
//
//  Created by FHDone on 15/1/16.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//

#import "INIParser.h"

@interface INIParser ()

@end

@implementation INIParser


+ (NSMutableDictionary*)iniParse:(NSString*) filename{
    NSMutableDictionary *songsDict = [NSMutableDictionary dictionary];
    
    NSString* path  = [[NSBundle mainBundle] pathForResource:filename ofType:@"ini"];

    
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    for (NSString *line in [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        NSArray *split = [line componentsSeparatedByString:@"|"];
        
        if (split.count == 2 ){
            NSString *name = [split firstObject];
            NSString *url = [split lastObject];
            name = [INIParser trim:name];
            url = [INIParser trim:url];
//            NSLog(@"%@" , name);
//            NSLog(@"%@" , url);
            [songsDict setObject:url forKey:name];
            
        }
    }
    
    return songsDict;
}

+(NSString*)trim:(NSString*) str{
    return  [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}



@end