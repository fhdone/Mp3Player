//
//  Mp3PlayerTests.m
//  Mp3PlayerTests
//
//  Created by FHDone on 15/1/12.
//  Copyright (c) 2015年 com.fhdone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSString+TimeToString.h"

//http://www.it165.net/pro/html/201403/10828.html
//command + U

@interface Mp3PlayerTests : XCTestCase

@end

@implementation Mp3PlayerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    NSLog(@"%@" , [NSString stringFromTime:315]  );
    NSLog(@"%@" , [NSString stringFromTime:1315]  );
    NSLog(@"%@" , [NSString stringFromTime:10001]  );
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
