//
//  RPRepo.m
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPRepo.h"

#import "NSError+RPGitErrors.h"

#import <git2/repository.h>
#import <git2/threads.h>
#import <git2/errors.h>

@implementation RPRepo

+ (NSError *)startup
{
    int r = git_threads_init();
    if (r != GIT_OK) {
        return [NSError rp_gitErrorForCode:r description:@"git_threads_init failed"];
    }
        
    return nil;
}

- (void)dealloc
{
    git_repository_free(_gitRepository);
}

- (instancetype)initWithGitRepository:(git_repository *)repository
{
    NSParameterAssert(repository != nil);
    if ((self = [super init])) {
        _gitRepository = repository;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error
{
    NSParameterAssert(url != nil);
    
    if (!url.isFileURL || !url.path) {
        if (error) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Invalid file path URL." };
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnsupportedSchemeError userInfo:userInfo];
        }
        return nil;
    }
    
    git_repository *repo = NULL;
    int gitError = git_repository_open(&repo, url.path.fileSystemRepresentation);
    if (gitError < GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to open repository at URL %@.", url];
        }
        return nil;
    }
    
    return [self initWithGitRepository:repo];
}

- (NSString *)path
{
    const char *path = git_repository_path(self.gitRepository);
    return path ? @(path) : @"";
}

- (NSString *)workingDirectory
{
    const char *path = git_repository_workdir(self.gitRepository);
    return path ? @(path) : @"";
}

@end
