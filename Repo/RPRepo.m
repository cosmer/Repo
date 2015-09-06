//
//  RPRepo.m
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPRepo.h"

#import "RPReference.h"
#import "RPOID.h"
#import "RPCommit.h"
#import "RPIndex.h"
#import "RPObject.h"
#import "NSError+RPGitErrors.h"

#import <git2/global.h>
#import <git2/repository.h>
#import <git2/submodule.h>
#import <git2/merge.h>
#import <git2/checkout.h>
#import <git2/revparse.h>
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

+ (BOOL)startupWithError:(NSError **)error
{
    int gitError = git_libgit2_init();
    if (gitError < 0) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"libgit2 initialization failed"];
        }
        return NO;
    }
    return YES;
}

- (void)dealloc
{
    git_repository_free(_gitRepository);
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
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

- (RPOID *)mergeBaseOfOID:(RPOID *)oid1 withOID:(RPOID *)oid2 error:(NSError **)error
{
    NSParameterAssert(oid1 != nil);
    NSParameterAssert(oid2 != nil);
    
    git_oid base;
    int gitError = git_merge_base(&base, self.gitRepository, oid1.gitOID, oid2.gitOID);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Couldn't find merge base of %@ and %@.", oid1, oid2];
        }
        return nil;
    }
    
    return [[RPOID alloc] initWithGitOID:&base];
}

- (RPIndex *)mergeOurCommit:(RPCommit *)ourCommit withTheirCommit:(RPCommit *)theirCommit error:(NSError **)error
{
    NSParameterAssert(ourCommit != nil);
    NSParameterAssert(theirCommit != nil);
    
    git_index *index = NULL;
    int gitError = git_merge_commits(&index, self.gitRepository, ourCommit.gitCommit, theirCommit.gitCommit, NULL);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to merge commits"];
        }
        return nil;
    }

    return [[RPIndex alloc] initWithGitIndex:index];
}

- (BOOL)forceCheckoutFileAtPath:(NSString *)path error:(NSError **)error
{
    NSParameterAssert(path != nil);

    git_checkout_options options = GIT_CHECKOUT_OPTIONS_INIT;
    options.checkout_strategy = GIT_CHECKOUT_FORCE | GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH;
    
    char *pathString = strdup(path.UTF8String);
    options.paths.count = 1;
    options.paths.strings = &pathString;
    
    int gitError = git_checkout_head(self.gitRepository, &options);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to checkout file %@", path];
        }
        
        free(pathString);
        return NO;
    }
    
    free(pathString);
    return YES;
}

- (RPObject *)revParseSingle:(NSString *)spec error:(NSError **)error
{
    NSParameterAssert(spec != nil);
    
    git_object *object = NULL;
    int gitError = git_revparse_single(&object, self.gitRepository, spec.UTF8String);
    if (gitError != GIT_OK){
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to parse revision string '%@'", spec];
        }
        return nil;
    }
    
    return [[RPObject alloc] initWithGitObject:object];
}

- (BOOL)isSubmoduleWorkingDirectoryDirty:(NSString *)path
{
    NSParameterAssert(path != nil);
    
    unsigned int status = 0;
    if (git_submodule_status(&status, self.gitRepository, path.UTF8String, GIT_SUBMODULE_IGNORE_NONE) < 0) {
        return NO;
    }
    
    return (GIT_SUBMODULE_STATUS_IS_WD_DIRTY(status) ? YES : NO);
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
