//
//  NSError+RPGitErrors.h
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const RPGitErrorDomain;

@interface NSError (RPGitErrors)

+ (NSError *)rp_gitErrorForCode:(int)code description:(NSString *)description, ...;

@end
