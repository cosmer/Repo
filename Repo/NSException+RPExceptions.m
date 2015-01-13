//
//  NSException+RPExceptions.m
//  Repo
//
//  Created by Charles Osmer on 1/11/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "NSException+RPExceptions.h"

@implementation NSException (RPExceptions)

+ (void)rp_raiseSelector:(SEL)selector notImplementedForClass:(Class)cls
{
    [NSException raise:NSGenericException format:@"%@ not implemented for class %@", NSStringFromSelector(selector), NSStringFromClass(cls)];
}

@end
