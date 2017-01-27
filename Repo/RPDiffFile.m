//
//  RPDiffFile.m
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPDiffFile.h"
#import "RPDiffFile+Private.h"

#import "RPOID.h"

_Static_assert(sizeof(((RPFileTime *)(NULL))->seconds) == sizeof(((git_diff_file_time *)(NULL))->seconds), "");
_Static_assert(sizeof(((RPFileTime *)(NULL))->nanoseconds) == sizeof(((git_diff_file_time *)(NULL))->nanoseconds), "");

static RPFileTime MakeFileTime(const git_diff_file_time *fileTime)
{
    return (RPFileTime){
        .seconds = fileTime->seconds,
        .nanoseconds = fileTime->nanoseconds
    };
}

@interface RPDiffFile ()

@property(nonatomic, readonly) uint32_t flags;

@end

@implementation RPDiffFile

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitDiffFile:(git_diff_file)diffFile
{
    if ((self = [super init])) {
        _path = @(diffFile.path);
        _oid = [[RPOID alloc] initWithGitOID:&diffFile.id];
        _flags = diffFile.flags;
        _mode = diffFile.mode;
        _ctime = MakeFileTime(&diffFile.ctime);
        _mtime = MakeFileTime(&diffFile.mtime);
        _size = diffFile.size;
    }
    return self;
}

- (BOOL)isBinary
{
    return _flags & GIT_DIFF_FLAG_BINARY ? YES : NO;
}

- (BOOL)isText
{
    return _flags & GIT_DIFF_FLAG_NOT_BINARY ? YES : NO;
}

- (BOOL)hasValidID
{
    return _flags & GIT_DIFF_FLAG_VALID_ID ? YES : NO;
}

- (BOOL)fileExists
{
    return _flags & GIT_DIFF_FLAG_EXISTS ? YES : NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Diff file \"%@\" [%@]", self.path, RPFileModeName(self.mode)];
}

@end
