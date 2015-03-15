//
//  NSException+RPExceptions.h
//  Repo
//
//  Created by Charles Osmer on 1/11/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSException (RPExceptions)

+ (void)rp_raiseSelector:(SEL)selector notImplementedForClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
