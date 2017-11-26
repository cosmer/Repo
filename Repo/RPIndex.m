//
//  RPIndex.m
//  Repo
//
//  Created by Charles Osmer on 4/20/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPIndex.h"

#import "Utilities.h"
#import "NSError+RPGitErrors.h"

#import <git2/index.h>
#import <git2/errors.h>

_Static_assert(RPIndexAddOptionForce == GIT_INDEX_ADD_FORCE, "");
_Static_assert(RPIndexAddOptionDisablePathspecMatch == GIT_INDEX_ADD_DISABLE_PATHSPEC_MATCH, "");
_Static_assert(RPIndexAddOptionCheckPathspec == GIT_INDEX_ADD_CHECK_PATHSPEC, "");

@implementation RPIndex

- (void)dealloc
{
    git_index_free(_gitIndex);
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitIndex:(git_index *)index
{
    NSParameterAssert(index != NULL);
    if ((self = [super init])) {
        _gitIndex = index;
    }
    return self;
}

- (BOOL)addFileAtPath:(NSString *)path error:(NSError **)error
{
    NSParameterAssert(path != nil);

    int gitError = git_index_add_bypath(self.gitIndex, path.UTF8String);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return NO;
    }

    return YES;
}

- (BOOL)removeFileAtPath:(NSString *)path stage:(int)stage error:(NSError **)error
{
    int gitError = git_index_remove(self.gitIndex, path.UTF8String, stage);
    if (gitError < 0) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return NO;
    }
    return YES;
}

- (BOOL)addFilesMatchingPathspecs:(NSArray<NSString *> *)pathspecs withOptions:(RPIndexAddOption)options error:(NSError **)error
{
    CLEANUP_GIT_STR_ARRAY git_strarray array = {0};
    copy_to_git_str_array(&array, pathspecs);

    int gitError = git_index_add_all(self.gitIndex, &array, (unsigned int)options, NULL, NULL);
    if (gitError < 0) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return NO;
    }
    return YES;
}

- (BOOL)writeWithError:(NSError **)error
{
    int gitError = git_index_write(self.gitIndex);
    if (gitError < 0) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return NO;
    }
    return YES;
}

@end
