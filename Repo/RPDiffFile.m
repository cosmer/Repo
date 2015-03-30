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
#import "NSException+RPExceptions.h"

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

@interface RPDiffFile ()

@property(nonatomic, readonly) uint32_t flags;

@end

@implementation RPDiffFile

- (instancetype)initWithGitDiffFile:(git_diff_file)diffFile
{
    if ((self = [super init])) {
        _path = @(diffFile.path);
        _oid = [[RPOID alloc] initWithGitOID:&diffFile.id];
        _flags = diffFile.flags;
        _mode = diffFile.mode;
    }
    return self;
}

- (BOOL)isBinary
{
    return _flags & GIT_DIFF_FLAG_BINARY;
}

- (BOOL)isText
{
    return _flags & GIT_DIFF_FLAG_NOT_BINARY;
}

- (BOOL)hasValidID
{
    return _flags & GIT_DIFF_FLAG_VALID_ID;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[RPDiffFile class]]) {
        return NO;
    }
    
    RPDiffFile *file = object;
    return (self.mode == file.mode &&
            self.flags == file.flags &&
            [self.oid isEqual:file.oid] &&
            [self.path isEqualToString:file.path]);
}

- (NSUInteger)hash
{
    [NSException rp_raiseSelector:_cmd notImplementedForClass:self.class];
    return 0;
}

@end
