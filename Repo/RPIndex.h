//
//  RPIndex.h
//  Repo
//
//  Created by Charles Osmer on 4/20/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

typedef struct git_index git_index;

typedef NS_OPTIONS(NSUInteger, RPIndexAddOption) {
    RPIndexAddOptionForce                   = 1 << 0,
    RPIndexAddOptionDisablePathspecMatch    = 1 << 1,
    RPIndexAddOptionCheckPathspec           = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface RPIndex : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `index`.
- (instancetype)initWithGitIndex:(git_index *)index NS_DESIGNATED_INITIALIZER;

/// Add or update file at path relative to the repo's working directory.
- (BOOL)addFileAtPath:(NSString *)path error:(NSError **)error;

/// Remove file at path relative to the repo's working directory.
- (BOOL)removeFileAtPath:(NSString *)path stage:(int)stage error:(NSError **)error;

/// Add all files matching the given pathspecs, or all files if no pathspecs are given.
- (BOOL)addFilesMatchingPathspecs:(NSArray<NSString *> *)pathspecs withOptions:(RPIndexAddOption)options error:(NSError **)error;

/// Write index to disk.
- (BOOL)writeWithError:(NSError **)error;

@property(nonatomic, readonly) git_index *gitIndex RP_RETURNS_INTERIOR_POINTER;

@end

NS_ASSUME_NONNULL_END
