//
//  RPIndex.m
//  Repo
//
//  Created by Charles Osmer on 4/20/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPIndex.h"

#import "RPOID.h"
#import "RPDiffFile.h"
#import "NSError+RPGitErrors.h"

#import <git2/index.h>
#import <git2/errors.h>

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
            *error = [NSError rp_gitErrorForCode:gitError description:@"Couldn't add file at '%@'", path];
        }
        return NO;
    }

    return YES;
}

- (BOOL)addDiffFile:(RPDiffFile *)file error:(NSError **)error
{
    git_index_entry entry = {0};
    entry.mode = file.mode;
    entry.path = file.path.UTF8String;
    git_oid_cpy(&entry.id, file.oid.gitOID);

    int gitError = git_index_add(self.gitIndex, &entry);
    if (gitError < 0) {
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
