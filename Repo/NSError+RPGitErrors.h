//
//  NSError+RPGitErrors.h
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const RPGitErrorDomain;

@interface NSError (RPGitErrors)

+ (nullable NSError *)rp_lastGitError;

+ (NSError *)rp_gitErrorForCode:(int)code description:(nullable NSString *)description, ...;

@end

NS_ASSUME_NONNULL_END
