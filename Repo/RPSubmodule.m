//
//  RPSubmodule.m
//  Repo
//
//  Created by Charles Osmer on 1/6/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPSubmodule.h"

#import "RPRepo.h"
#import "NSError+RPGitErrors.h"

#import <git2/errors.h>
#import <git2/buffer.h>
#import <git2/submodule.h>

@implementation RPSubmodule

- (void)dealloc
{
    git_submodule_free(_gitSubmodule);
}

- (instancetype)initWithGitSubmodule:(git_submodule *)submodule
{
    NSParameterAssert(submodule != NULL);
    if ((self = [super init])) {
        _gitSubmodule = submodule;
    }
    return self;
}

- (instancetype)initWithRepo:(RPRepo *)repo path:(NSString *)path error:(NSError **)error
{
    NSParameterAssert(repo != nil);
    NSParameterAssert(path.length > 0);
    
    git_submodule *submodule = NULL;
    int gitError = git_submodule_lookup(&submodule, repo.gitRepository, path.UTF8String);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Submodule lookup failed"];
        }
        return nil;
    }
    
    return [self initWithGitSubmodule:submodule];
}

- (BOOL)isWorkingDirectoryDirty
{
    unsigned int status = 0;
    if (git_submodule_status(&status, self.gitSubmodule) != GIT_OK) {
        return NO;
    }

    return (GIT_SUBMODULE_STATUS_IS_WD_DIRTY(status) ? YES : NO);
}

@end
