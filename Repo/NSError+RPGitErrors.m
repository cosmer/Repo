//
//  NSError+RPGitErrors.m
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "NSError+RPGitErrors.h"

NSString * const RPGitErrorDomain = @"RPGitErrorDomain";

@implementation NSError (RPGitErrors)

+ (NSError *)rp_gitErrorForCode:(int)code description:(NSString *)description, ...
{
    NSString *formattedDescription = nil;
    if (description) {
        va_list args;
        va_start(args, description);
        formattedDescription = [[NSString alloc] initWithFormat:description arguments:args];
        va_end(args);
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if (formattedDescription) {
        userInfo[NSLocalizedDescriptionKey] = formattedDescription;
    }
    
    return [[NSError alloc] initWithDomain:RPGitErrorDomain code:code userInfo:userInfo];
}

@end
