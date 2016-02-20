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

- (NSString *)description
{
    return [NSString stringWithFormat:@"Diff file \"%@\" [%@]", self.path, RPFileModeName(self.mode)];
}

@end
