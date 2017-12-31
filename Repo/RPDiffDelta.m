//
//  RPDiffDelta.m
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPDiffDelta.h"
#import "RPDiffDelta+Private.h"

#import "RPDiff.h"
#import "RPDiffFile.h"
#import "RPDiffFile+Private.h"
#import "NSException+RPExceptions.h"

#import <git2/diff.h>

_Static_assert(RPDiffDeltaStatusUnmodified == GIT_DELTA_UNMODIFIED, "");
_Static_assert(RPDiffDeltaStatusAdded == GIT_DELTA_ADDED, "");
_Static_assert(RPDiffDeltaStatusDeleted == GIT_DELTA_DELETED, "");
_Static_assert(RPDiffDeltaStatusModified == GIT_DELTA_MODIFIED, "");
_Static_assert(RPDiffDeltaStatusRenamed == GIT_DELTA_RENAMED, "");
_Static_assert(RPDiffDeltaStatusCopied == GIT_DELTA_COPIED, "");
_Static_assert(RPDiffDeltaStatusIgnored == GIT_DELTA_IGNORED, "");
_Static_assert(RPDiffDeltaStatusUntracked == GIT_DELTA_UNTRACKED, "");
_Static_assert(RPDiffDeltaStatusTypeChange == GIT_DELTA_TYPECHANGE, "");
_Static_assert(RPDiffDeltaStatusUnreadable == GIT_DELTA_UNREADABLE, "");
_Static_assert(RPDiffDeltaStatusConflicted == GIT_DELTA_CONFLICTED, "");

NSString *RPDiffDeltaStatusName(RPDiffDeltaStatus status)
{
    switch (status) {
        case RPDiffDeltaStatusUnmodified:
            return @"Unmodified";
        case RPDiffDeltaStatusAdded:
            return @"Added";
        case RPDiffDeltaStatusDeleted:
            return @"Deleted";
        case RPDiffDeltaStatusModified:
            return @"Modified";
        case RPDiffDeltaStatusRenamed:
            return @"Renamed";
        case RPDiffDeltaStatusCopied:
            return @"Copied";
        case RPDiffDeltaStatusIgnored:
            return @"Ignored";
        case RPDiffDeltaStatusUntracked:
            return @"Untracked";
        case RPDiffDeltaStatusTypeChange:
            return @"Type Change";
        case RPDiffDeltaStatusUnreadable:
            return @"Unreadable";
        case RPDiffDeltaStatusConflicted:
            return @"Conflicted";
    }
    
    return [NSString stringWithFormat:@"RPDiffDeltaStatus{%ld}", (long)status];
}

NSString *RPDiffDeltaStatusLetter(RPDiffDeltaStatus status)
{
    if (status == RPDiffDeltaStatusConflicted) {
        return @"!";
    }

    const char l = git_diff_status_char((git_delta_t)status);
    return [NSString stringWithFormat:@"%c", l];
}

@implementation RPDiffDelta

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithDiff:(RPDiff *)diff deltaIndex:(NSUInteger)deltaIndex location:(RPDiffLocation)location
{
    NSParameterAssert(diff != nil);
    const git_diff_delta *delta = git_diff_get_delta(diff.gitDiff, deltaIndex);
    return [self initWithGitDiffDelta:delta location:location];
}

- (instancetype)initWithGitDiffDelta:(const git_diff_delta *)delta location:(RPDiffLocation)location
{
    NSParameterAssert(delta != NULL);
    if ((self = [super init])) {
        _location = location;
        _status = (RPDiffDeltaStatus)delta->status;
        _oldFile = [[RPDiffFile alloc] initWithGitDiffFile:delta->old_file];
        _newFile = [[RPDiffFile alloc] initWithGitDiffFile:delta->new_file];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object class] != [RPDiffDelta class]) {
        return NO;
    }

    RPDiffDelta *delta = object;
    return (self.location == delta.location &&
            self.status == delta.status &&
            [self.oldFile isEqual:delta.oldFile] &&
            [self.newFile isEqual:delta.newFile]);
}

- (NSUInteger)hash
{
    [NSException rp_raiseSelector:_cmd notImplementedForClass:self.class];
    return 0;
}

@end
