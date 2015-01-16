//
//  INIParser.h
//  Mp3Player
//
//  Created by FHDone on 15/1/16.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface INIParser : NSObject

+ (NSMutableDictionary*)iniParse:(NSString*) filename;

@end