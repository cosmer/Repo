//
//  RPBlob.m
//  Repo
//
//  Created by Charles Osmer on 11/21/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPBlob.h"

#import "RPRepo.h"
#import "RPOID.h"
#import "RPCommit.h"
#import "NSError+RPGitErrors.h"

#import <git2/blob.h>
#import <git2/errors.h>

@interface RPBlob ()

@property(nonatomic, readonly) git_blob *gitBlob;
@property(nonatomic, readonly) git_off_t size;

@end

@implementation RPBlob

- (void)dealloc
{
    git_object_free(_gitObject);
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitObject:(git_object *)object inRepo:(RPRepo *)repo
{
    NSParameterAssert(object != NULL);
    NSParameterAssert(repo != nil);
    if ((self = [super init])) {
        _gitObject = object;
        _repo = repo;
    }
    return self;
}

- (instancetype)initWithOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    NSParameterAssert(repo != nil);
    
    git_object *object = NULL;
    int gitError = git_object_lookup(&object, repo.gitRepository, oid.gitOID, GIT_OBJ_BLOB);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [self initWithGitObject:object inRepo:repo];
}

- (nullable instancetype)initWithCommit:(RPCommit *)commit path:(NSString *)path inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(commit != nil);
    NSParameterAssert(path != nil);
    NSParameterAssert(repo != nil);

    git_object *object = NULL;
    int gitError = git_object_lookup_bypath(&object, (const git_object *)commit.gitCommit, path.UTF8String, GIT_OBJ_BLOB);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }

    return [self initWithGitObject:object inRepo:repo];
}

- (git_blob *)gitBlob
{
    return (git_blob *)self.gitObject;
}

- (git_off_t)rawSize
{
    return git_blob_rawsize(self.gitBlob);
}

- (const char *)rawContent
{
    return git_blob_rawcontent(self.gitBlob);
}

- (NSData *)data
{
    const void *content = git_blob_rawcontent(self.gitBlob);
    return [NSData dataWithBytes:content length:self.rawSize];
}

@end
