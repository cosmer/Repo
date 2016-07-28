//
//  NSError+RPGitErrors.m
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "NSError+RPGitErrors.h"

#import <git2/errors.h>

NSString * const RPLibGit2ErrorDomain = @"RPLibGit2ErrorDomain";
NSString * const RPRepoErrorDomain = @"RPRepoErrorDomain";

@implementation NSError (RPGitErrors)

+ (NSError *)rp_lastGitError
{
    NSInteger code = -1;
    NSString *description = nil;

    const git_error *error = giterr_last();
    if (error) {
        code = error->klass;
        if (error->message) {
            description = @(error->message);
        }
    }

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if (description.length > 0) {
        userInfo[NSLocalizedDescriptionKey] = description;
    }
    else {
        userInfo[NSLocalizedDescriptionKey] = @"An unknown error occurred.";
    }

    return [[NSError alloc] initWithDomain:RPLibGit2ErrorDomain code:code userInfo:userInfo];
}

+ (NSError *)rp_repoErrorWithDescription:(NSString *)description, ...
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
    
    return [[NSError alloc] initWithDomain:RPRepoErrorDomain code:0 userInfo:userInfo];
}

@end
