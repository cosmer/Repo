//
//  RPRepo.m
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPRepo.h"

#import "RPReference.h"
#import "NSError+RPGitErrors.h"

#import <git2/global.h>
#import <git2/repository.h>
#import <git2/attr.h>
#import <git2/errors.h>

@implementation RPRepo

+ (BOOL)isRepositoryAtURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    BOOL isDir = NO;
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSURL *gitURL = [url URLByAppendingPathComponent:@".git"];
    if (![fm fileExistsAtPath:gitURL.path isDirectory:&isDir]) {
        return NO;
    }
    
    if (!isDir) {
        return YES; // submodule
    }
    
    NSURL *headURL = [gitURL URLByAppendingPathComponent:@"HEAD"];
    if (![fm fileExistsAtPath:headURL.path isDirectory:&isDir] || isDir) {
        return NO;
    }
    
    NSURL *objectsURL = [gitURL URLByAppendingPathComponent:@"objects"];
    if (![fm fileExistsAtPath:objectsURL.path isDirectory:&isDir] || !isDir) {
        return NO;
    }

    return YES;
}

+ (NSError *)startup
{
    git_libgit2_init();
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

- (NSString *)stringEncodingNameForPath:(NSString *)path
{
    NSParameterAssert(path != nil);
    
    const char *value = NULL;
    if (git_attr_get(&value, self.gitRepository, GIT_ATTR_CHECK_FILE_THEN_INDEX, path.UTF8String, "encoding") != GIT_OK) {
        return nil;
    }
    
    if (!value || !GIT_ATTR_HAS_VALUE(value)) {
        return nil;
    }
    
    return @(value);
}

- (RPReference *)head
{
    git_reference *ref = NULL;
    if (git_repository_head(&ref, self.gitRepository) != GIT_OK) {
        return nil;
    }
    
    return [[RPReference alloc] initWithGitReference:ref];
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
