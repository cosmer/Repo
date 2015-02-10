//
//  NSError+RPGitErrors.h
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang assume_nonnull begin

extern NSString * const RPGitErrorDomain;

@interface NSError (RPGitErrors)

+ (NSError *)rp_gitErrorForCode:(int)code description:(nullable NSString *)description, ...;

@end

#pragma clang assume_nonnull end
