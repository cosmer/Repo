//
//  RepoTests.m
//  RepoTests
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "Utilities.h"

@interface RepoTests : XCTestCase

@end

@implementation RepoTests

- (void)testExample
{
    XCTAssertTrue(strcmp(remove_prefix("", ""), "") == 0);
    XCTAssertTrue(strcmp(remove_prefix("foo", ""), "foo") == 0);
    XCTAssertTrue(strcmp(remove_prefix("foo", "foo"), "") == 0);
    XCTAssertTrue(strcmp(remove_prefix("foo/bar", "foo/"), "bar") == 0);

    XCTAssertEqual(remove_prefix("", "bar"), NULL);
    XCTAssertEqual(remove_prefix("foo", "bar"), NULL);
    XCTAssertEqual(remove_prefix("foo", "foo/bar"), NULL);
}

@end
