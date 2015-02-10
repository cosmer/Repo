//
//  NSException+RPExceptions.h
//  Repo
//
//  Created by Charles Osmer on 1/11/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang assume_nonnull begin

@interface NSException (RPExceptions)

+ (void)rp_raiseSelector:(SEL)selector notImplementedForClass:(Class)cls;

@end

#pragma clang assume_nonnull end
