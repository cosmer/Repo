//
//  RPTypes.m
//  Repo
//
//  Created by Charles Osmer on 3/29/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPTypes.h"

#import <git2/types.h>

_Static_assert(RPObjectTypeAny == GIT_OBJ_ANY, "");
_Static_assert(RPObjectTypeBad  == GIT_OBJ_BAD, "");
_Static_assert(RPObjectTypeCommit == GIT_OBJ_COMMIT, "");
_Static_assert(RPObjectTypeTree == GIT_OBJ_TREE, "");
_Static_assert(RPObjectTypeBlob == GIT_OBJ_BLOB, "");
_Static_assert(RPObjectTypeTag == GIT_OBJ_TAG, "");
_Static_assert(RPObjectTypeOfsDelta == GIT_OBJ_OFS_DELTA, "");
_Static_assert(RPObjectTypeRefDelta == GIT_OBJ_REF_DELTA, "");

_Static_assert(RPBranchTypeLocal == GIT_BRANCH_LOCAL, "");
_Static_assert(RPBranchTypeRemote == GIT_BRANCH_REMOTE, "");
_Static_assert(RPBranchTypeAll == GIT_BRANCH_ALL, "");

_Static_assert(RPFileModeUnreadable == GIT_FILEMODE_UNREADABLE, "");
_Static_assert(RPFileModeTree == GIT_FILEMODE_TREE, "");
_Static_assert(RPFileModeBlob == GIT_FILEMODE_BLOB, "");
_Static_assert(RPFileModeBlobExecutable == GIT_FILEMODE_BLOB_EXECUTABLE, "");
_Static_assert(RPFileModeLink == GIT_FILEMODE_LINK, "");
_Static_assert(RPFileModeCommit == GIT_FILEMODE_COMMIT, "");

NSString *RPFileModeName(RPFileMode mode)
{
    switch (mode) {
        case RPFileModeUnreadable:
            return @"Unreadable";
        case RPFileModeTree:
            return @"Tree";
        case RPFileModeBlob:
            return @"Blob";
        case RPFileModeBlobExecutable:
            return @"Executable Blob";
        case RPFileModeLink:
            return @"Link";
        case RPFileModeCommit:
            return @"Commit";
    }
    
    return [NSString stringWithFormat:@"RPFileMode{%ld}", (long)mode];
}

NSString *RPObjectTypeName(RPObjectType type)
{
    switch (type) {
        case RPObjectTypeAny:
            return @"Any";
        case RPObjectTypeBad:
            return @"Bad";
        case RPObjectTypeCommit:
            return @"Commit";
        case RPObjectTypeTree:
            return @"Tree";
        case RPObjectTypeBlob:
            return @"Blob";
        case RPObjectTypeTag:
            return @"Tag";
        case RPObjectTypeOfsDelta:
            return @"OfsDelta";
        case RPObjectTypeRefDelta:
            return @"RefDelta";
    }
    
    return [NSString stringWithFormat:@"RPObjectType{%ld}", (long)type];
}

NSString *RPBranchTypeName(RPBranchType type)
{
    switch (type) {
        case RPBranchTypeAll:
            return @"All";
        case RPBranchTypeLocal:
            return @"Local";
        case RPBranchTypeRemote:
            return @"Remote";
    }
    
    return [NSString stringWithFormat:@"RPBranchType{%ld}", (long)type];
}

NSString *RPDiffLocationName(RPDiffLocation location)
{
    switch (location) {
        case RPDiffLocationOther:
            return @"Other";
        case RPDiffLocationIndex:
            return @"Index";
        case RPDiffLocationWorkdir:
            return @"Workdir";
        case RPDiffLocationWorkdirWithIndex:
            return @"WorkdirWithIndex";
    }

    return [NSString stringWithFormat:@"RPDiffLocation{%@}", @(location)];
}
