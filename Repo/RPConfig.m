//
//  RPConfig.m
//  Repo
//
//  Created by Charles Osmer on 1/26/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPConfig.h"

#import "RPRepo.h"
#import "NSError+RPGitErrors.h"

#import <git2/config.h>
#import <git2/repository.h>
#import <git2/errors.h>

@implementation RPConfig

- (void)dealloc
{
    git_config_free(_gitConfig);
}

- (instancetype)initWithRepo:(RPRepo *)repo error:(NSError **)error
{
    git_config *config = NULL;
    int gitError = git_repository_config(&config, repo.gitRepository);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to open repository config"];
        }
        return nil;
    }
    
    return [self initWithGitConfig:config];
}

- (instancetype)initWithGitConfig:(git_config *)config
{
    NSParameterAssert(config != NULL);
    if ((self = [super init])) {
        _gitConfig = config;
    }
    return self;
}

- (NSString *)stringWithName:(NSString *)name
{
    NSParameterAssert(name.length > 0);
    
    const char *string = NULL;
    if (git_config_get_string(&string, self.gitConfig, name.UTF8String) != GIT_OK) {
        return nil;
    }
    
    return (string ? @(string) : nil);
}

@end
