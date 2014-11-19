//
//  RPDiffDelta.m
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPDiffDelta.h"

#import "RPDiff.h"
#import "RPDiffFile.h"
#import "RPDiffFile+Private.h"

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

@implementation RPDiffDelta

- (instancetype)initWithDiff:(RPDiff *)diff deltaIndex:(NSUInteger)deltaIndex
{
    NSParameterAssert(diff != nil);
    if ((self = [super init])) {
        _diff = diff;
        _deltaIndex = deltaIndex;
    }
    return self;
}

- (const git_diff_delta *)gitDiffDelta
{
    return git_diff_get_delta(self.diff.gitDiff, self.deltaIndex);
}

- (RPDiffDeltaStatus)status
{
    return (RPDiffDeltaStatus)self.gitDiffDelta->status;
}

- (RPDiffFile *)oldFile
{
    return [[RPDiffFile alloc] initWithGitDiffFile:self.gitDiffDelta->old_file];
}

- (RPDiffFile *)newFile
{
    return [[RPDiffFile alloc] initWithGitDiffFile:self.gitDiffDelta->new_file];
}

@end
