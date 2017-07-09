//
//  RPObject.m
//  Repo
//
//  Created by Charles Osmer on 3/29/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPObject.h"

#import "RPOID.h"
#import "RPRepo.h"
#import "RPCleanup.h"
#import "NSError+RPGitErrors.h"

#import <git2/object.h>
#import <git2/repository.h>
#import <git2/odb.h>
#import <git2/errors.h>

@implementation RPObject

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

+ (instancetype)lookupOID:(RPOID *)oid withType:(RPObjectType)type inRepo:(RPRepo *)repo error:(NSError **)error
{
    git_object *object = NULL;
    int gitError = git_object_lookup(&object, repo.gitRepository, oid.gitOID, (git_otype)type);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [[RPObject alloc] initWithGitObject:object];
}

+ (NSNumber *)sizeOfObjectWithOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    NSParameterAssert(repo != nil);

    CLEANUP_GIT_ODB git_odb *odb = NULL;
    if (git_repository_odb(&odb, repo.gitRepository) != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }

    size_t len = 0;
    git_otype type = 0;
    if (git_odb_read_header(&len, &type, odb, oid.gitOID) != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }

    return @(len);
}

- (void)dealloc
{
    git_object_free(_gitObject);
}

- (instancetype)initWithGitObject:(git_object *)gitObject
{
    NSParameterAssert(gitObject != NULL);
    if ((self = [super init])) {
        _gitObject = gitObject;
    }
    return self;
}

- (RPOID *)OID
{
    const git_oid *oid = git_object_id(self.gitObject);
    return [[RPOID alloc] initWithGitOID:oid];
}

- (instancetype)peelToType:(RPObjectType)type error:(NSError **)error
{
    git_object *peeled = NULL;
    int gitError = git_object_peel(&peeled, self.gitObject, (git_otype)type);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [[RPObject alloc] initWithGitObject:peeled];
}

@end
